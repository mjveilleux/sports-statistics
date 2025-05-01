


-- we will have a table that contains the same team_id across seasons, but within seasons, team stuff changes
-- here we can then do the matchups according to team_id rather than team_nm
-- we will also be able to have the model correctly match up conf/division/sub-division for matchups

DROP TABLE IF EXISTS nfl.team_alltime;

CREATE TABLE nfl.team_alltime (

season  INTEGER,
team_id INTEGER,
team_nm VARCHAR,
team_location VARCHAR,
team_nm_location VARCHAR,
team_location_abbreviation VARCHAR,
conference_nm VARCHAR,
division_nm VARCHAR,
conference_id INTEGER,
conference_division_nm VARCHAR,
division_id INTEGER,
season_id INTEGER
  );

INSERT INTO nfl.team_alltime
SELECT    
  season,
  team_id,
  team_nm,
  team_location,
  team_nm_location,
  team_location_abbreviation,
  conference_nm,
  division_nm,
  conference_id,
  conference_division_nm,
  division_id,
  season_id 
FROM read_csv_auto('~/Documents/GitHub/sports-statistics/data/team_alltime.csv') 
where team_id is not null





