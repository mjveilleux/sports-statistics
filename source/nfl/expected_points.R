

library(tidyverse)
library(rstan)


pbp = nflreadr::load_pbp(seasons = 2024)

pbp$fixed_drive_result %>% unique()



# team map 
all_teams <- unique(c(pbp$posteam, pbp$defteam))
team_map <- tibble(team = all_teams, team_id = seq_along(all_teams))

test_data_full <- pbp %>% 
  filter(epa != 0) %>% 
  select(game_id,posteam,defteam,home_team,week,season,epa) %>% 
  left_join(team_map %>% rename(posteam_id = team_id), by = c("posteam" = "team")) %>%
  left_join(team_map %>% rename(defteam_id = team_id), by = c("defteam" = "team")) %>% 
  mutate(home_team_id = ifelse(posteam == home_team,posteam_id,defteam_id),
         away_team_id = ifelse(posteam == home_team,defteam_id,posteam_id))
  

test_data_full

stan_data = list(
  plays = nrow(test_data_full),
  W = test_data_full$week,
  weeks = max(test_data_full$week),
  teams = length(unique(test_data_full$posteam)),
  epa = test_data_full$epa,
  OFF = test_data_full$posteam_id,
  DEF = test_data_full$defteam_id,
  H = test_data_full$home_team_id,
  A = test_data_full$away_team_id
)


# Fit the model
fit <- stan(
  file = "v3_expected_points.stan",
  data = stan_data,
  chains = 4,
  warmup = 1000,
  iter = 2000,
  cores = 4
)


print(fit, pars = c("alpha", "thetas", "sigma_epa", "sigma_teams"))

# Extract results
posterior_samples <- extract(fit)

# Home field advantage
hfa_estimate <- mean(posterior_samples$alpha)
cat("Home Field Advantage:", round(hfa_estimate, 3), "EPA\n")

# Team strengths
team_strengths <- apply(posterior_samples$thetas, 2, mean)
team_strength_sd <- apply(posterior_samples$thetas, 2, sd)

# Create results dataframe
results <- data.frame(
  team = 1:stan_data$teams,  # Replace with actual team names
  strength = team_strengths,
  strength_sd = team_strength_sd
) %>%
  arrange(desc(strength))

print(results)



rnorm(500,0.02169755, 0.06287252) %>% hist()
