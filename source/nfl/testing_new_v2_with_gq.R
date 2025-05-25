library(tidyverse)
library(plotly)
library(bayesplot)
library(duckdb)
library(nflfastR)
library(rstan)


# lets write a blog on the code below.
# main findings that I want to share:
  # in-sample vs out-of-sample comparisons (the 2024 season)
  # the model fits the data well when looking at wins
  # when we forecast the thetas, there is a lot of change that can happen across seaons
  # analysis of the 2024 season
    # we'll use the table of wins and median strengths to tell the story of the 2024 season outcome 
    # why some teams did better and others worse (explaining the differences in wins vs median team strength estimate)
    # cheifs and eagles specifically -- allude model that takes apart off and def strengths would show a better picture for the Chiefs
      # acquiring Barkely took the Eagles offense to a different level something unexpected in the model
# take-aways: a lot can happen in the off-season / develop over a season 
# every year is a new year filled with great variances in outcomes



prepare_stan_data_season_overall_strength <- function(historical_games, team_alltime) {
  
  # Get scalar values using tidyverse
  teams_count <- team_alltime %>% 
    select(team_id) %>% 
    unique() %>% 
    nrow()
  
  games_count <- nrow(historical_games)
  
  seasons_count <- historical_games %>% 
    select(season) %>% 
    unique() %>% 
    nrow()
  
  # Create the stan_data list with proper formats
  stan_data <- list(
    teams = teams_count,
    games = games_count,
    seasons = seasons_count,
    conferences = 2,
    H = historical_games %>% pull(team_id_home) %>% as.integer(),
    A = historical_games %>% pull(team_id_away) %>% as.integer(),
    S = historical_games %>% pull(season_index) %>% as.integer(),
    h_point_diff = historical_games %>% pull(home_point_diff) %>% as.integer(),
    h_adv = historical_games %>% pull(h_adv) %>% as.integer(),
    team_conference = historical_games %>% pull(conference_id) %>% as.integer()
  )
  
  return(stan_data)
}

run_stan_model <- function(stan_data, 
                           model_file, 
                           output_dir = "./output",
                           chains = 4, 
                           iter = 2000,
                           warmup = 1000, 
                           seed = 123456,
                           control = list(adapt_delta = 0.8, max_treedepth = 10)) {
  #' Run a Stan model using rstan with the provided data.
  #' 
  #' @param stan_data List containing the data for the Stan model.
  #' @param model_file Character string path to the Stan model file.
  #' @param output_dir Character string directory to save the output files.
  #' @param chains Integer number of Markov chains, default is 4.
  #' @param iter Integer total number of iterations per chain, default is 2000.
  #' @param warmup Integer number of warmup iterations, default is 1000.
  #' @param seed Integer random seed, default is 123456.
  #' @param control List of control parameters for the sampler.
  #' 
  #' @return stanfit object with the fitted Stan model and samples.
  
  # Create output directory if it doesn't exist
  if (!dir.exists(output_dir)) {
    dir.create(output_dir, recursive = TRUE)
  }
  
  # Run the model (rstan compiles automatically)
  fit <- stan(
    file = model_file,
    data = stan_data,
    chains = chains,
    iter = iter,
    warmup = warmup,
    seed = seed,
    control = control,
    verbose = TRUE
  )

  return(fit)
}

# Connect to DuckDB
con <- dbConnect(duckdb::duckdb(), dbdir = "/Users/masonveilleux/.duckdb/cli/1.2.1/mydatabase.duckdb")

# Get historical data
nfl_data <- nflfastR::fast_scraper_schedules() %>% filter(season > 1999)

# Get teams_alltime from duckdb
team_alltime <- dbGetQuery(con, "SELECT * FROM nfl.team_alltime;")

# Clean the NFL data
clean_nfl_data <- nfl_data %>% 
  filter(game_type == "REG") %>% 
  select(
    game_id,
    week,
    season,
    team_location_abbr_home = home_team,
    team_location_abbr_away = away_team,
    location,
    points_home = home_score,
    points_away = away_score
  ) %>% 
  mutate(
    week_season_id = paste(week, season, sep = "-"),
    home_win_flg = ifelse(points_home > points_away, TRUE, FALSE)
  )

# Join with team_alltime to get team_id for home teams
df_with_home_ids <- clean_nfl_data %>%
  left_join(
    team_alltime %>% 
      select(season, team_id, team_location_abbreviation,conference_id) %>%
      rename(team_id_home = team_id),
    by = c("season", "team_location_abbr_home" = "team_location_abbreviation")
  )

df_with_home_ids %>% 
  select(team_location_abbr_home,team_id_home)


# Join with team_alltime to get team_id for away teams
final_df <- df_with_home_ids %>%
  inner_join(
    team_alltime %>% 
      select(season, team_id, team_location_abbreviation) %>%
      rename(team_id_away = team_id),
    by = c("season", "team_location_abbr_away" = "team_location_abbreviation")
  ) %>%
  select(
    game_id,
    week,
    season,
    week_season_id,
    team_id_home,
    team_id_away,
    location,
    points_home,
    points_away,
    home_win_flg,
    conference_id
  ) %>% 
  mutate(home_point_diff = points_home - points_away,
         h_adv = ifelse(location == "Home",1,0),
         season_index = as.numeric(factor(season, levels = sort(unique(season))))) %>% 
  drop_na(home_point_diff)


duckdb::dbDisconnect(con)

max(final_df$season)

final_df %>% filter(season == 2024)



stan_data = prepare_stan_data_season_overall_strength(
  historical_games = final_df, 
  team_alltime = team_alltime
  )


fit = run_stan_model(
  stan_data = stan_data,model_file = '../../model/stan/season/v2.stan', chains = 1
)

# plot theta team strength forecast 
fit


# Extract results
posterior_samples <- extract(fit)

# do softmax in R? 

mean(posterior_samples$theta)

library(tidyverse)
library(rstan)
library(bayesplot)
library(ggplot2)
library(dplyr)
library(plotly)

# Function to extract and summarize team strengths from Stan fit
extract_team_strengths <- function(fit, team_alltime, final_df) {
  
  # Extract posterior samples
  posterior_samples <- extract(fit)
  
  # Get dimensions
  n_teams <- dim(posterior_samples$thetas)[2]
  n_seasons <- dim(posterior_samples$thetas)[3]
  
  # Get unique seasons from data
  seasons <- sort(unique(final_df$season))
  
  # Get team information
  team_info <- team_alltime %>%
    filter(season == max(team_alltime$season)) %>% 
    select(team_id, team_location_abbreviation, team_nm) %>%
    distinct()
  
  # Extract theta_forecast summary for all teams
  theta_forecast_summary <- data.frame(
    season = 2024,
    team = team_alltime %>% filter(season ==2024) %>% pull(team_nm),
    theta_median = apply(posterior_samples$theta_forecast, 2, median),
    theta_lower = apply(posterior_samples$theta_forecast, 2, quantile, 0.025),
    theta_upper = apply(posterior_samples$theta_forecast, 2, quantile, 0.975)
  )
  
  # Create results table
  results_table <- expand_grid(
    season = seasons,
    team_id = 1:n_teams
  ) %>%
    arrange(team_id, season)
  
  # Calculate historical theta summaries and add to table
  for (i in 1:nrow(results_table)) {
    t <- results_table$team_id[i]
    s <- which(seasons == results_table$season[i])
    
    theta_samples <- posterior_samples$thetas[, t, s]
    results_table$theta_median[i] <- median(theta_samples)
    results_table$theta_lower[i] <- quantile(theta_samples, 0.025)
    results_table$theta_upper[i] <- quantile(theta_samples, 0.975)
  }
  
  # Add team information and forecast data
  results_table <- results_table %>%
    left_join(team_info, by = c("team_id")) %>%
    select(
      season,
      team = team_nm,
      theta_median,
      theta_lower,
      theta_upper    ) %>% 
    rbind(theta_forecast_summary)
  
  return(results_table)
}



fit_extract_thetas = extract_team_strengths(fit = fit, team_alltime = team_alltime, final_df = final_df)

fit_extract_thetas = fit_extract_thetas %>% 
  mutate(forecast = ifelse(season == 2024, 'forecast','model'))


ggplot(fit_extract_thetas %>%  filter(team %in% c('Chiefs','Eagles')) , aes(x = season, y = theta_median, color = forecast)) +
  geom_errorbar(aes(ymin = theta_lower, ymax = theta_upper), 
                width = 0.2, alpha = 0.7) +
  geom_line(size = 1) +
  geom_point(size = 1.5) +
  facet_wrap(~ team) +
  scale_color_manual(values = c("model" = "#2E86AB", "forecast" = "#F24236")) +
  labs(
    title = "Team Performance Over Time with Forecasts",
    subtitle = "Error bars show uncertainty (theta_lower to theta_upper)",
    x = "Season",
    y = "Theta (Median)",
    color = "Type"
  ) +
  theme_minimal() +
  theme(
    strip.text = element_text(face = "bold"),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )


# Your data preparation code
wins_by_season = nfl_data %>% 
  filter(game_type == "REG") %>% 
  mutate(winner = ifelse(home_score > away_score, home_team, away_team)) %>% 
  group_by(season, winner) %>% 
  summarize(wins = length(winner), .groups = 'drop') %>% 
  inner_join(
    team_alltime %>% select(team_location_abbreviation, team_nm, season), 
    by = c("winner" = "team_location_abbreviation", "season")
  ) %>% 
  rename(team = team_nm)

# Fixed plot
fit_extract_thetas %>% 
  left_join(wins_by_season, by = c("season", "team")) %>% 
  ggplot(aes(x = theta_median, y = wins, color = forecast)) +
  geom_errorbarh(aes(xmin = theta_lower, xmax = theta_upper), 
                 height = 0.2, alpha = 0.7) +
  geom_point(size = 2) +
  facet_wrap(~ season, scales = "free") +
  scale_color_manual(values = c("model" = "#2E86AB", "forecast" = "#F24236")) +
  labs(
    title = "Team Wins vs Theta Strength",
    subtitle = "Horizontal error bars show theta uncertainty",
    x = "Theta (Team Strength)",
    y = "Wins",
    color = "Type"
  ) +
  theme_minimal() +
  theme(
    strip.text = element_text(face = "bold"),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )


# Fixed plot
fit_extract_thetas %>% 
  left_join(wins_by_season, by = c("season", "team")) %>% 
  filter(season == 2024) %>% View()
  ggplot(aes(x = theta_median, y = wins, color = forecast)) +
  # geom_errorbarh(aes(xmin = theta_lower, xmax = theta_upper), 
  #                height = 0.2, alpha = 0.7) +
  geom_point(size = 2) +
  scale_color_manual(values = c("model" = "#2E86AB", "forecast" = "#F24236")) +
  labs(
    title = "Team Wins vs Theta Strength",
    subtitle = "Horizontal error bars show theta uncertainty",
    x = "Theta (Team Strength)",
    y = "Wins",
    color = "Type"
  ) +
  theme_minimal() +
  theme(
    strip.text = element_text(face = "bold"),
    legend.position = "bottom",
    panel.grid.minor = element_blank()
  )

