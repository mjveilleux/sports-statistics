



DROP TABLE IF EXISTS nfl.model_summary_team_strength_model_v2;

CREATE TABLE nfl.model_summary_team_strength_model_v2 as 

with model as (

SELECT 
  parameters,
  'team_strength' AS parameter_type,
  CAST(REGEXP_EXTRACT(parameters, 'thetas\[(\d+),', 1) AS INTEGER) AS team_id,
  CAST(REGEXP_EXTRACT(parameters, ',(\d+)\]', 1) AS INTEGER) AS season_id,
  median,
  perc_5,
  perc_95
FROM nfl.stan_output_model_v2
WHERE parameters LIKE 'thetas%'
)
SELECT 
m.parameters 
,m.parameter_type
,m.team_id 
,m.season_id
,m.median 
,m.perc_5
,m.perc_95
,t.team_nm
,t.season
,t.division_nm
,t.conference_nm
,t.conference_division_nm
FROM model as m 
INNER JOIN nfl.team_alltime as t on t.season_id = m.season_id and t.team_id = m.team_id

