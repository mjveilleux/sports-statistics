

-- this summarizes weekly team strength estimates and playoff potential
-- basically summarizes over the season

CREATE TABLE nfl.season_summary (
    team_id VARCHAR,
    team_name VARCHAR,
    season INTEGER,
    week INTEGER,
    season_week_id VARCHAR,
    strength_estimate_median FLOAT,
    strength_estimate_10 FLOAT,
    strength_estimate_90 FLOAT,
    prob_best_overall FLOAT,
    prob_best_subdivision FLOAT,
    prob_best_division FLOAT,
    prob_best_conference FLOAT,
    prob_playoff FLOAT , -- probability of making the playoffs ever (we can do seeds later)
    updated_ts TIMESTAMP
);
