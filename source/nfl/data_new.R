
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
# Close the connection when done
dbDisconnect(con)


nfl_data %>% 
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
  mutate(week_season_id = paste(week,season,'-'),
          home_win_flag = ifelse(points_home > points_away,TRUE,FALSE))




