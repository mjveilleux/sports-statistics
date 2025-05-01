
drop table if exists nfl.historical_games_points; 

CREATE TABLE nfl.historical_games_points (
    game_id VARCHAR,        -- or INTEGER, depending on your ID format
    week INTEGER,
    season INTEGER,         -- or VARCHAR if you store seasons like "2023-2024"
    week_season_id VARCHAR, -- or INTEGER
    team_id_home INTEGER,   -- or VARCHAR
    team_id_away INTEGER,   -- or VARCHAR
    location VARCHAR,
    points_home INTEGER,
    points_away INTEGER,
    home_win_flg BOOLEAN,    -- or INTEGER (0/1) or VARCHAR ('Y'/'N')
    home_point_diff INTEGER,
    h_adv INTEGER,
    season_index INTEGER
);


INSERT INTO nfl.historical_games_points
SELECT * FROM read_parquet('~/Documents/GitHub/sports-statistics/data/historical_games_points.parquet');


