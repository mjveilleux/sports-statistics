
-- this table is long formatted

drop table if exists nfl.historical_games_expected_points; 

CREATE TABLE nfl.historical_games_expected_points (
    game_id VARCHAR,
    week INTEGER,
    season INTEGER,
    week_season_id VARCHAR,
    team_id_home VARCHAR,
    team_id_away VARCHAR,
    location VARCHAR,
    expected_points_home DOUBLE,
    expected_points_away DOUBLE,
    home_win_flg BOOLEAN,
    h_adv INTEGER,
    game_index INTEGER,
    season_index INTEGER
);


INSERT INTO nfl.historical_games_expected_points
SELECT * FROM read_parquet('~/Documents/GitHub/sports-statistics/data/historical_games_expected_points.parquet');


