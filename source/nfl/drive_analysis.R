


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
  file = "v1_drives.stan",
  data = stan_data,
  chains = 4,
  warmup = 1000,
  iter = 2000,
  cores = 4
)
