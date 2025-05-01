


drop table if exists nfl.stan_output_model_v2;

create table nfl.stan_output_model_v2 (
parameters VARCHAR,
Mean FLOAT,
MCSE FLOAT,
StdDev FLOAT,
MAD FLOAT,
perc_5 FLOAT,
median FLOAT,
perc_95 FLOAT,
ESS_bulk FLOAT,
ESS_tail FLOAT,
R_hat FLOAT
);

insert into nfl.stan_output_model_v2
select * 
from read_csv_auto('~/Documents/GitHub/sports-statistics/model/out/fit_summary.csv') 
  where parameters is not null;


select parameters,median,perc_5,perc_95 
from nfl.stan_output_model_v2
where parameters like 'thetas%'
