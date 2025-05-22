


# drive outcomes for week by week team strength estimates

# columns:
  # season index
  # week index
  # offensive team index
  # defensive team index
  # choice (0,3,6)
  # off team HFA (0,1)
  # def team HFA (0,1)
  # off team off bye week (0,1)
  # def team off bye week (0,1)

# each observation is a drive

library(tidyverse)
library(rstan)

pbp = nflreadr::load_pbp(seasons = 2024)

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
        week
         ) %>% 
  unique() %>% 
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

# team map 
all_teams <- unique(c(df$posteam, df$defteam))
team_map <- tibble(team = all_teams, team_id = seq_along(all_teams))

df <- df %>%
  left_join(team_map %>% rename(posteam_id = team_id), by = c("posteam" = "team")) %>%
  left_join(team_map %>% rename(defteam_id = team_id), by = c("defteam" = "team"))

stan_data = list(
  drives_nbr = nrow(df), 
  weeks_nbr = max(df$week),
  week  = df$week,
  teams_nbr = length(unique(df$posteam)),
  posteam_id = df$posteam_id,
  defteam_id = df$defteam_id,
  posteam_hfa = df$posteam_home_flg,
  defteam_hfa = df$defteam_home_flg,
  choice = df$choice
)

stan_data

# Fit the model
fit <- stan(
  file = "drives_test.stan",
  data = stan_data,
  chains = 4,
  warmup = 1000,
  iter = 2000,
  cores = 4
)

posterior <- extract(fit)
teams_nbr = length(unique(df$posteam))
weeks_nbr = max(df$week)
# Create team names for better visualization
team_names <- paste0("Team ", 1:teams_nbr)

# Function to plot strength over weeks
plot_strength_over_weeks <- function(strength_matrix, title, color_palette = "RdYlBu") {
  # Calculate median values for each team in each week
  strength_df <- data.frame(matrix(apply(strength_matrix, c(2, 3), median), 
                                   nrow = weeks_nbr, 
                                   ncol = teams_nbr))
  colnames(strength_df) <- team_names
  strength_df$Week <- 1:weeks_nbr
  
  # Convert to long format for ggplot
  strength_long <- strength_df %>%
    pivot_longer(cols = -Week, names_to = "Team", values_to = "Strength")
  
  # Plot
  ggplot(strength_long, aes(x = Week, y = Strength, color = Team, group = Team)) +
    geom_line(size = 1) +
    geom_point(size = 2) +
    scale_color_brewer(palette = color_palette) +
    theme_minimal() +
    labs(title = title,
         x = "Week",
         y = "Strength") +
    theme(legend.position = "bottom",
          legend.text = element_text(size = 8),
          plot.title = element_text(hjust = 0.5, face = "bold"))
}

# 1. Plot offensive strength over weeks
off_plot <- plot_strength_over_weeks(posterior$off_strength, 
                                     "Offensive Strength by Team Over Weeks", 
                                     "RdYlBu")

# 2. Plot defensive strength over weeks
def_plot <- plot_strength_over_weeks(posterior$def_strength, 
                                     "Defensive Strength by Team Over Weeks", 
                                     "RdYlBu")

# 3. Compare Week 5 offensive and defensive strengths
plot_week_comparison <- function(off_strength, def_strength, week_num = 5) {
  # Extract week 5 data
  off_week5 <- off_strength[, week_num, ]
  def_week5 <- def_strength[, week_num, ]
  
  # Calculate median values
  off_median <- apply(off_week5, 2, median)
  def_median <- apply(def_week5, 2, median)
  
  # Create data frame
  week5_df <- data.frame(
    Team = team_names,
    Offensive = off_median,
    Defensive = def_median
  )
  
  # Convert to long format
  week5_long <- week5_df %>%
    pivot_longer(cols = c(Offensive, Defensive), 
                 names_to = "Strength_Type", 
                 values_to = "Value")
  
  # Plot
  ggplot(week5_long, aes(x = reorder(Team, Value), y = Value, fill = Strength_Type)) +
    geom_bar(stat = "identity", position = "dodge") +
    coord_flip() +
    scale_fill_brewer(palette = "Set1") +
    theme_minimal() +
    labs(title = paste("Week", week_num, "Offensive vs Defensive Strength"),
         x = "Team",
         y = "Strength",
         fill = "Strength Type") +
    theme(plot.title = element_text(hjust = 0.5, face = "bold"))
}

week5_comparison <- plot_week_comparison(posterior$off_strength, 
                                         posterior$def_strength, 
                                         week_num = 5)

# Display plots
print(off_plot)
print(def_plot)
print(week5_comparison)

# Function to compare any week's offensive and defensive strengths
# This function allows you to manually update the week as requested
compare_week_strengths <- function(fit, week_to_analyze = 5) {
  posterior <- extract(fit)
  plot_week_comparison(posterior$off_strength, posterior$def_strength, week_num = week_to_analyze)
}

# Example of how to use the function to analyze different weeks
# compare_week_strengths(fit, 10)  # To analyze week 10

# Summary of model results
summary_stats <- summary(fit, pars = c("sigma_off", "sigma_def", "sigma_off_week", "sigma_def_week"))$summary
print(summary_stats)

# Additional analysis: Team strength rankings
analyze_team_rankings <- function(fit, week_to_analyze = NULL) {
  posterior <- extract(fit)
  
  # Get global strengths if no specific week is provided
  if (is.null(week_to_analyze)) {
    off_strength <- posterior$off_strength_global
    def_strength <- posterior$def_strength_global
    title_prefix <- "Global"
  } else {
    off_strength <- posterior$off_strength[, week_to_analyze, ]
    def_strength <- posterior$def_strength[, week_to_analyze, ]
    title_prefix <- paste("Week", week_to_analyze)
  }
  
  # Calculate median values
  off_median <- apply(off_strength, if(is.null(week_to_analyze)) 2 else 1, median)
  def_median <- apply(def_strength, if(is.null(week_to_analyze)) 2 else 1, median)
  
  # Create ranking data frames
  off_ranks <- data.frame(
    Team = team_names,
    Strength = off_median,
    Rank = rank(-off_median)
  ) %>% arrange(Rank)
  
  def_ranks <- data.frame(
    Team = team_names,
    Strength = def_median,
    Rank = rank(-def_median)
  ) %>% arrange(Rank)
  
  # Print rankings
  cat(paste(title_prefix, "Offensive Rankings:\n"))
  print(off_ranks)
  
  cat(paste("\n", title_prefix, "Defensive Rankings:\n"))
  print(def_ranks)
  
  # Return data frames for further use
  return(list(offensive = off_ranks, defensive = def_ranks))
}

# Example usage
global_rankings <- analyze_team_rankings(fit)
week5_rankings <- analyze_team_rankings(fit, week_to_analyze = 5)