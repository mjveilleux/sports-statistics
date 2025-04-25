

# these should be one time loads

# team-division information
team_divisions = nflseedR::divisions

# get urls for team info
nflfastR::teams_colors_logos

# schedules with game results , odds, other info
nflseedR::load_schedules() %>% colnames()

# summary table for stan prep 

nfl_data_clean



team_division_index


season_week_index