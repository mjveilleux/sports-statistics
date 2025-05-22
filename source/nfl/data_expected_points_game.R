library(tidyverse)
library(duckdb)
library(nflfastR)
library(arrow)
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
      select(season, team_id, team_location_abbr) %>%
      rename(team_id_home = team_id),
    by = c("season", "team_location_abbr_home" = "team_location_abbr")
  )

df_with_home_ids %>% 
  select(team_location_abbr_home,team_id_home)


# Join with team_alltime to get team_id for away teams
final_df <- df_with_home_ids %>%
  left_join(
    team_alltime %>% 
      select(season, team_id, team_location_abbr) %>%
      rename(team_id_away = team_id),
    by = c("season", "team_location_abbr_away" = "team_location_abbr")
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
    home_win_flg
  ) %>% 
  mutate(home_point_diff = points_home - points_away,
         h_adv = ifelse(location == "Home",1,0),
         season_index = as.numeric(factor(season, levels = sort(unique(season)))))


final_df %>% 
  select(game_id,team_id_home,team_id_away) %>% 
  filter(team_id_home %>% is.na())

unique(final_df$h_adv)

unique(final_df$season_index)

arrow::write_parquet(final_df,sink = '../../data/historical_games_points.parquet')

duckdb::dbDisconnect(con)

