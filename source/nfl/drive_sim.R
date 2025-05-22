


# sumulate match 


# choice on drive:
  # 0,3,6 

# if 6, then evaluate probability of going for 1,2 pt conversion given:
  # minute of game 
  # score differential
  # timeouts left

# then probability of success of 1 or 2 for each team 

# that should simulate strengths and nicely simulate game outcomes 



# but we also need to simulate drive time elapsed and drives left 

# then we can simulate games completely

# drive duration 
  # minutes left till forced re-posession (half or full time)
  # timeouts left
  # by team


# the paramters of interest are:
  # 



library(tidyverse)
library(rstan)
library(brms)
library(bayesplot)


pbp = nflreadr::load_pbp(seasons = 2023:2024)

pbp$fixed_drive_result %>% unique()

df = pbp %>% 
  select(game_id,
         fixed_drive,
         posteam,
         defteam,
         # drive_start_yard_line,
         # drive_end_yard_line,
         # drive_ended_with_score,
         fixed_drive_result,
         home_team,
         week,
         season
  ) %>% 
  unique() %>% 
  #filter(week == 4) %>% 
  drop_na(posteam) %>%
  mutate(
    choice = case_when(
      fixed_drive_result == "Touchdown" ~ 6,
      fixed_drive_result == "Field goal" ~ 3,
      TRUE ~ 0
    ),
    posteam_home_flg = ifelse(posteam == home_team,1,0),
    defteam_home_flg = ifelse(defteam == home_team,1,0),
  )



df = df %>% 
  select(posteam,defteam,posteam_home_flg,choice,season)










# Complete RStan fitting code for drive outcome model
library(rstan)
library(dplyr)
library(bayesplot)
library(ggplot2)
library(posterior)

# Set RStan options for better performance
options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

# Prepare data for Stan model (assuming drives_df is your dataframe)
# Create team mapping (alphabetical for consistency)
team_names <- sort(unique(c(df$posteam, df$defteam)))
team_mapping <- data.frame(
  team = team_names,
  team_id = 1:length(team_names)
)

# Create season mapping
season_names <- sort(unique(df$season))
season_mapping <- data.frame(
  season = season_names,
  season_id = 1:length(season_names)
)

# Prepare the data for Stan
stan_data_prep <- df %>%
  # Map teams to integers
  left_join(team_mapping, by = c("posteam" = "team")) %>%
  rename(posteam_id = team_id) %>%
  left_join(team_mapping, by = c("defteam" = "team")) %>%
  rename(defteam_id = team_id) %>%
  # Map seasons to integers
  left_join(season_mapping, by = "season") %>%
  # Recode choice: 0->1 (turnover), 3->2 (FG), 6->3 (TD)
  mutate(
    choice_stan = case_when(
      choice == 0 ~ 1L,  # turnover
      choice == 3 ~ 2L,  # field goal
      choice == 6 ~ 3L,  # touchdown
      TRUE ~ NA_integer_
    )
  ) %>%
  # Create home/away team indicators based on possession
  mutate(
    H = ifelse(posteam_home_flg == 1, posteam_id, defteam_id),  # home team
    A = ifelse(posteam_home_flg == 1, defteam_id, posteam_id)   # away team
  ) %>%
  # Remove any rows with missing choice values
  filter(!is.na(choice_stan))

# Create Stan data list
stan_data <- list(
  drives = nrow(stan_data_prep),
  teams = length(team_names),
  seasons = length(season_names),
  choice = stan_data_prep$choice_stan,
  H = stan_data_prep$H,
  A = stan_data_prep$A,
  S = stan_data_prep$season_id
)

# Print data summary
cat("Stan data summary:\n")
cat("Number of drives:", stan_data$drives, "\n")
cat("Number of teams:", stan_data$teams, "\n")  
cat("Number of seasons:", stan_data$seasons, "\n")
cat("Choice distribution:\n")
print(table(stan_data$choice))

# Compile the Stan model (assuming your .stan file is named "drive_model.stan")
model <- stan_model(file = "v1_drives.stan")

# Set sampling parameters
n_chains <- 4
n_iter <- 2000
n_warmup <- 1000
n_thin <- 1

# Fit the model
cat("Starting Stan sampling...\n")
start_time <- Sys.time()

fit <- sampling(
  object = model,
  data = stan_data,
  chains = n_chains,
  iter = n_iter,
  warmup = n_warmup,
  thin = n_thin,
  cores = parallel::detectCores(),
  seed = 123,
  control = list(
    adapt_delta = 0.95,
    max_treedepth = 12
  )
)

end_time <- Sys.time()
cat("Sampling completed in:", round(difftime(end_time, start_time, units = "mins"), 2), "minutes\n")

# Model diagnostics
cat("\n=== MODEL DIAGNOSTICS ===\n")

# Check convergence
print(fit, pars = c("alpha", "cutpoints", "sigma_off_team", "sigma_def_team", "sigma_seasons", "phi_s"))

# Rhat values
rhat_vals <- summary(fit)$summary[, "Rhat"]
max_rhat <- max(rhat_vals, na.rm = TRUE)
cat("Maximum Rhat:", round(max_rhat, 4), "\n")

if (max_rhat > 1.1) {
  cat("WARNING: Some Rhat values > 1.1, indicating convergence issues\n")
} else {
  cat("All Rhat values look good (< 1.1)\n")
}

# Effective sample size
n_eff <- summary(fit)$summary[, "n_eff"]
min_n_eff <- min(n_eff, na.rm = TRUE)
cat("Minimum n_eff:", round(min_n_eff, 0), "\n")

# Divergent transitions
sampler_params <- get_sampler_params(fit, inc_warmup = FALSE)
divergent <- sum(sapply(sampler_params, function(x) sum(x[, "divergent__"])))
cat("Number of divergent transitions:", divergent, "\n")

if (divergent > 0) {
  cat("WARNING: Divergent transitions detected. Consider increasing adapt_delta\n")
}

# Model diagnostics plots
mcmc_trace(fit, pars = c("alpha", "cutpoints[1]", "cutpoints[2]", "phi_s"))
ggsave("trace_plots.png", width = 10, height = 8)

mcmc_rhat(rhat(fit))
ggsave("rhat_plot.png", width = 8, height = 6)

# Extract and summarize key parameters
cat("\n=== KEY PARAMETER SUMMARIES ===\n")

# Global parameters
global_params <- extract(fit, pars = c("alpha", "cutpoints", "sigma_off_team", 
                                       "sigma_def_team", "sigma_seasons", "phi_s"))

cat("Alpha (baseline):", round(mean(global_params$alpha), 3), 
    "±", round(sd(global_params$alpha), 3), "\n")
cat("Phi_s (AR persistence):", round(mean(global_params$phi_s), 3), 
    "±", round(sd(global_params$phi_s), 3), "\n")

# Team strengths for most recent season
off_thetas <- extract(fit, "off_thetas")[[1]]
def_thetas <- extract(fit, "def_thetas")[[1]]

# Get most recent season index
recent_season <- max(stan_data_prep$season_id)

# Calculate posterior means for most recent season
team_results <- data.frame(
  team = team_names,
  off_mean = apply(off_thetas[, , recent_season], 2, mean),
  off_sd = apply(off_thetas[, , recent_season], 2, sd),
  def_mean = apply(def_thetas[, , recent_season], 2, mean),
  def_sd = apply(def_thetas[, , recent_season], 2, sd)
) %>%
  mutate(
    net_rating = off_mean - def_mean,
    season = max(season_names)
  ) %>%
  arrange(desc(net_rating))

cat("\nTop 10 teams (most recent season):\n")
print(head(team_results, 10))

cat("\nBottom 10 teams (most recent season):\n")
print(tail(team_results, 10))

# Save results 
save(fit, stan_data, team_mapping, season_mapping, team_results, 
     file = "drive_model_results.RData")

cat("\nResults saved to drive_model_results.RData\n")

# Function to extract team trends across seasons
extract_team_trends <- function(fit, team_name, team_mapping, season_mapping) {
  team_id <- team_mapping$team_id[team_mapping$team == team_name]
  
  off_thetas <- extract(fit, "off_thetas")[[1]]
  def_thetas <- extract(fit, "def_thetas")[[1]]
  
  trends <- data.frame(
    season = season_mapping$season,
    off_mean = apply(off_thetas[, team_id, ], 2, mean),
    off_lower = apply(off_thetas[, team_id, ], 2, quantile, 0.025),
    off_upper = apply(off_thetas[, team_id, ], 2, quantile, 0.975),
    def_mean = apply(def_thetas[, team_id, ], 2, mean),
    def_lower = apply(def_thetas[, team_id, ], 2, quantile, 0.025),
    def_upper = apply(def_thetas[, team_id, ], 2, quantile, 0.975)
  )
  
  return(trends)
}

# Example: Plot trends for a specific team
# team_trends <- extract_team_trends(fit, "WAS", team_mapping, season_mapping)
# ggplot(team_trends, aes(x = season)) +
#   geom_line(aes(y = off_mean), color = "blue") +
#   geom_ribbon(aes(ymin = off_lower, ymax = off_upper), alpha = 0.3, fill = "blue") +
#   geom_line(aes(y = def_mean), color = "red") +
#   geom_ribbon(aes(ymin = def_lower, ymax = def_upper), alpha = 0.3, fill = "red") +
#   labs(title = "Team Strength Over Time", 
#        subtitle = "Blue = Offense, Red = Defense",
#        y = "Team Strength", x = "Season")

cat("\n=== ANALYSIS COMPLETE ===\n")
cat("Use extract_team_trends() function to analyze specific teams\n")
cat("Model fit object saved as 'fit'\n")
cat("Team results saved as 'team_results'\n")


