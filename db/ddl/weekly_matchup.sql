
-- we;ll need to use duckdb or postgres to do the array thing

-- this table summarizes the weekly matchups
-- this table will do the weekly matchups on the most up to date data.
-- the front end will show the whole season's matchups for each team
create table as nfl.weekly_matchup

game_id
team_id_home
team_id_away
season
week
season_week_id
prob_win_home
prob_win_away
-- array the below
sim_points_distribution_home
sim_points_distribution_away
updated_ts
