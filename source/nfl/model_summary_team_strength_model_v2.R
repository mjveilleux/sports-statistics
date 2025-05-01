

library(tidyverse)
library(duckdb)
library(nflfastR)
library(arrow)
# Connect to DuckDB
con <- dbConnect(duckdb::duckdb(), dbdir = "/Users/masonveilleux/.duckdb/cli/1.2.1/mydatabase.duckdb")

# Get historical data
nfl_data <- nflfastR::fast_scraper_schedules() %>% filter(season > 1999)

# Get teams_alltime from duckdb
team_alltime <- dbGetQuery(con, "SELECT * FROM nfl.model_summary_team_strength_model_v2;")
