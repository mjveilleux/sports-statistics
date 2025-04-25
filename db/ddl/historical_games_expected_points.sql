
-- this table is long formatted

CREATE TABLE nfl.historical_games_expected_points (
    game_id VARCHAR,
    week INTEGER,
    season INTEGER,
    week_season_id VARCHAR,
    team_id_home VARCHAR,
    team_id_away VARCHAR,
    expected_points_home DOUBLE,
    expected_points_away DOUBLE,
    mean_expected_points_home DOUBLE,
    mean_expected_points_away DOUBLE,
    sd_expected_points_home DOUBLE,
    sd_expected_points_away DOUBLE,
    nb_plays_home INTEGER,
    nb_plays_away INTEGER,
    home_win_flg BOOLEAN
);
