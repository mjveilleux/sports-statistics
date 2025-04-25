


-- we will have a table that contains the same team_id across seasons, but within seasons, team stuff changes
-- here we can then do the matchups according to team_id rather than team_nm
-- we will also be able to have the model correctly match up conf/division/sub-division for matchups

DROP TABLE IF EXISTS nfl.team_alltime;

CREATE TABLE nfl.team_alltime (
    season INTEGER,
    team_id VARCHAR,  -- this is constant through time/season
    team_nm VARCHAR,  -- this can change
    team_location VARCHAR,  -- this can change
    team_nm_location VARCHAR,  -- this concatenates team_nm and team_location e.g 'Arizona Cardinals'
    team_location_abbr VARCHAR,  -- the abbreviated version of team_location
    team_conference VARCHAR,  -- this can change
    team_division VARCHAR  -- this can change
);

-- INSERT INTO nfl.team_alltime
-- SELECT * FROM read_csv_auto('~/Documents/GitHub/sports-statistics/data/team_alltime.csv');

