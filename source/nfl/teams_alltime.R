

 nflreadr::load_teams() %>%
  group_by(team_id) %>% 
   summarise(n = n()) %>% 
   filter(n >1)


nflreadr::team_abbr_mapping
