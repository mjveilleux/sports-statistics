

library(tidyverse)
library(duckdb)
library(plotly)
# Connect to DuckDB
con <- dbConnect(duckdb::duckdb(), dbdir = "/Users/masonveilleux/.duckdb/cli/1.2.1/mydatabase.duckdb")

# Get teams_alltime from duckdb
model_summary <- dbGetQuery(con, "SELECT * FROM nfl.model_summary_team_strength_model_v2;")


p = model_summary %>% 
  filter(season > 2002) %>% 
  ggplot(aes(x = season, y = median, group = team_nm, color = team_nm))+
  geom_line()+
  facet_wrap(~conference_division_nm)

plotly::ggplotly(p)
Duckdb::dbDisconnect(con)
