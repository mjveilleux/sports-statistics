

library(tidyverse)
library(duckdb)
con <- dbConnect(duckdb::duckdb(), dbdir = "/Users/masonveilleux/.duckdb/cli/1.2.1/mydatabase.duckdb")

# Get historical data
schedules <- nflfastR::fast_scraper_schedules() %>% filter(season > 1999)

# Use simple table name
# duckdb R client is whack and I cant add table to schema? so putting in global thing
dbWriteTable(con, "nfl_schedules", schedules, overwrite = TRUE)
res <- dbGetQuery(con, "SELECT * FROM nfl_schedules LIMIT 1")

print(res)
dbDisconnect(con)
