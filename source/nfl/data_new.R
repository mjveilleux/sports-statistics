
# CREATE TABLE nfl.historical_games_points (
#   game_id VARCHAR,        -- or INTEGER, depending on your ID format
#   week INTEGER,
#   season INTEGER,         -- or VARCHAR if you store seasons like "2023-2024"
#   week_season_id VARCHAR, -- or INTEGER
#   team_id_home INTEGER,   -- or VARCHAR
#   team_id_away INTEGER,   -- or VARCHAR
#   location VARCHAR,
#   points_home INTEGER,
#   points_away INTEGER,
#   home_win_flg BOOLEAN    -- or INTEGER (0/1) or VARCHAR ('Y'/'N')
# );

library(tidyverse)
library(duckdb)
# make historical_games_points table

# get historical data
nfl_data <- nflfastR::fast_scraper_schedules() %>% filter(season > 1999)

# get teams_alltime from duckdb
con <- dbConnect(duckdb::duckdb(), dbdir = "/Users/masonveilleux/.duckdb/cli/1.2.1/mydatabase.duckdb")

# Example: Create a schema if it doesn't exist
dbExecute(con, "CREATE SCHEMA IF NOT EXISTS nfl;")

# Example: Query data
team_alltime <- dbGetQuery(con, "SELECT * FROM nfl.team_alltime;")
colnames(team_alltime
         )
team_alltime %>% tibble()
# Close the connection when done


clean_nfl_data = nfl_data %>% 
  filter(
    game_type == "REG"
  ) %>% 
  select(
    game_id,
    week,
    season,
    # week_season_id
    team_location_abbr_home = home_team,
    team_location_abbr_away = away_team,
    location,
    points_home = home_score,
    points_away = away_score,
    #home_win_flag
  ) %>% 
  mutate(week_season_id = paste(week,'-',season),
          home_win_flag = ifelse(points_home > points_away,TRUE,FALSE))


# df is final table
dbWriteTable(con, "nfl.historical_games_points", df, overwrite = TRUE)


dbDisconnect(con)

team_alltime$team_id

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
    H = historical_games %>% pull(team_id_home) %>% as.integer(),
    A = historical_games %>% pull(team_id_away) %>% as.integer(),
    S = historical_games %>% pull(season_index) %>% as.integer(),
    h_point_diff = historical_games %>% pull(home_point_diff) %>% as.integer(),
    h_adv = historical_games %>% pull(h_adv) %>% as.integer()
  )
  
  return(stan_data)
}


prepare_stan_data_season_overall_strength(historical_games = clean_nfl_data,team_alltime = team_alltime )



# test new v2 model












