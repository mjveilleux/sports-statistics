
# Prepare data for Stan model (rerwite this in python)


# make matrix of seasons, weeks

seasons_summary = nfl_data_clean %>% 
  group_by(season) %>% 
  summarize(
    N_weeks = max(week),
    N_games = length(unique(game_id)),
    N_teams = length(unique(c(home_team,away_team))) # get both home and away in case of week 1
  )


# Create the data list for Stan
stan_data <- list(
  N_games = sum(seasons_summary$N_games),
  N_teams = max(seasons_summary$N_teams),
  N_seasons = nrow(seasons_summary),
  ps = nfl_data_clean$ps,
  pa = nfl_data_clean$pa,
  y = c(nfl_data_clean$ps,nfl_data_clean$pa),
  d  = nfl_data_clean$ps - nfl_data_clean$pa,
  H = nfl_data_clean$H,
  A = nfl_data_clean$A,
  W = nfl_data_clean$W_index,
  S = nfl_data_clean$S,
  h_adv = nfl_data_clean$h_adv
)
# Print the data structure
str(stan_data)


