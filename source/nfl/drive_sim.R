


# sumulate match 


# choice on drive:
  # 0,3,6 

# if 6, then evaluate probability of going for 1,2 pt conversion given:
  # minute of game 
  # score differential
  # timeouts left

# then probability of success of 1 or 2 for each team 

# that should simulate strengths and nicely simulate game outcomes 



# but we also need to simulate drive time elapsed and drives left 

# then we can simulate games completely

# drive duration 
  # minutes left till forced re-posession (half or full time)
  # timeouts left
  # by team


# the paramters of interest are:
  # 



library(tidyverse)
library(rstan)
library(brms)
library(bayesplot)


pbp = nflreadr::load_pbp(seasons = 2024)

pbp$fixed_drive_result %>% unique()

df = pbp %>% 
  select(game_id,
         fixed_drive,
         posteam,
         defteam,
         # drive_start_yard_line,
         # drive_end_yard_line,
         # drive_ended_with_score,
         fixed_drive_result,
         home_team,
         week
  ) %>% 
  unique() %>% 
  #filter(week == 4) %>% 
  drop_na(posteam) %>%
  mutate(
    choice = case_when(
      fixed_drive_result == "Touchdown" ~ 6,
      fixed_drive_result == "Field goal" ~ 3,
      TRUE ~ 0
    ),
    posteam_home_flg = ifelse(posteam == home_team,1,0),
    defteam_home_flg = ifelse(defteam == home_team,1,0),
  )


basic_model = brm(
  bf(choice ~ (1 | posteam)),
  data = df,
  family = categorical())

basic_model %>% summary()
pp_check(basic_model)


# For the underlying parameters (log-odds scale)
param_summary <- posterior_summary(basic_model)
print(param_summary)

# For team-specific effects
ranef_summary <- ranef(basic_model)
print(ranef_summary)

# this is with one week: 


# Multilevel Hyperparameters:
#   ~posteam (Number of levels: 32) 
# Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
# sd(mu3_Intercept)     0.54      0.28     0.04     1.11 1.00     1048     1364
# sd(mu6_Intercept)     0.35      0.22     0.02     0.81 1.00      924     1726
# 
# Regression Coefficients:
#   Estimate Est.Error l-95% CI u-95% CI Rhat Bulk_ESS Tail_ESS
# mu3_Intercept    -1.53      0.20    -1.97    -1.17 1.00     2637     2228
# mu6_Intercept    -1.07      0.16    -1.39    -0.77 1.00     2732     2235


# this is with all weeks:


