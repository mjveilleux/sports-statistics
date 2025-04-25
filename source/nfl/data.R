library(nflfastR)
library(tidyverse)

single_season_year = 2024

# Fetch NFL game data for 2021 and 2022 seasons
nfl_data <- nflfastR::fast_scraper_schedules(seasons = single_season_year)

team_abbr_nick_pair = nflreadr::load_teams() %>% select(team_abbr,team_nick)

# Clean and prepare the data
nfl_data_clean <- nfl_data %>%
  left_join(team_abbr_nick_pair, by = c("home_team" = "team_abbr")) %>%
  rename(home_name_nick = team_nick) %>%
  left_join(team_abbr_nick_pair, by = c("away_team" = "team_abbr")) %>%
  rename(away_name_nick = team_nick) %>% 
  filter(game_type == 'REG') %>% 
  drop_na(home_score) %>% # drops any games that have not been played yet
  select(game_id, home_team,home_name_nick, away_team,away_name_nick, home_score, away_score, week, season) %>%
  mutate(
    ps = home_score,  # Points scored by home team
    pa = away_score,  # Points allowed by away team
    H = as.integer(factor(home_team)),  # Home team index
    A = as.integer(factor(away_team)),  # Away team index
    W = as.integer(factor(week)),  # Week index
    S = as.integer(factor(season)),  # Season index
    h_adv = 1
  )

# Add division information
team_divisions = nflseedR::divisions


# Merge division information into the clean data
nfl_data_clean <- nfl_data_clean %>%
  left_join(team_divisions, by = c("home_team" = "team")) %>%  # weird joins because of LA Rams/Chargers
  rename(home_division = division)

# make dictionary of teams/index
team_division_index = nfl_data_clean %>% select(team_nm = home_team, team_ind = H,home_division,sdiv) %>% distinct()

# make dictionary of season-weeks and index weeks
season_week_index = nfl_data_clean %>% select(season,week,W) %>% distinct() %>% mutate(W_index = row_number() )

nfl_data_clean = nfl_data_clean %>% 
  left_join(season_week_index) %>% 
  left_join()

# add the actual team name (not the city reference (this means we can span across time))

team_abbr_nick_pair = nflreadr::load_teams() %>% select(team_abbr,team_nick)




