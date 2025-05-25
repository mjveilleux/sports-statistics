data {
  int<lower=1> games;   // total games to evaluate
  int<lower=1> teams;            // number of teams
  int<lower=1> conferences; // number of conferences
  int<lower=2> seasons; // need two for prior in s+1
  
  array[games] real h_point_diff; // outcome: point differential (ps - pa)
  
  array[games] int<lower=1, upper=teams> H; // vector of home team indices
  array[games] int<lower=1, upper=teams> A; // vector of away team indices
  array[games] int<lower=1, upper=seasons> S; // vector of season indices

  array[games] int<lower=1,upper=conferences> team_conference; // vector of conference indices for each game
}

parameters {
  real alpha; // intercept (HFA)
  matrix[teams, seasons] thetas; // team strength coefficient for each team-season
  real<lower=0> sigma_games; // game-level variance in point differential
  real<lower=0> sigma_teams; // across team variance before season
  real<lower=0> sigma_seasons; // across season variance within team
  real<lower=0, upper=1> phi_s; // auto-regressive parameter for season prior
}

model {
  // game-level model
  for (g in 1:games) {
    h_point_diff[g] ~ normal(alpha + thetas[H[g],S[g]] - thetas[A[g],S[g]], sigma_games);
  }
  
  // team-level priors
  for (t in 1:teams) {
    // initial season prior across teams
    thetas[t, 1] ~ normal(0, sigma_teams);
    
    for (s in 2:seasons) {
      // AR(1) model across seasons
      thetas[t, s] ~ normal(phi_s * thetas[t, s-1], sigma_seasons);
    }
  }
}

generated quantities {

// calculate the team strength for each team in the last season
  array[teams] real theta_final;
  for (t in 1:teams) {
    theta_final[t] = thetas[t, seasons];
  }

// forecast team strengths for the next season using the last season's team strengths
  array[teams] real theta_forecast;
  for (t in 1:teams) {
    theta_forecast[t] = normal_rng(phi_s * theta_final[t],sigma_seasons);
  }

// convert theta_forecast to a simplex using a softmax transformation (using the softmax function)
  //array[teams] real theta_forecast_simplex;
 // theta_forecast_simplex = softmax(theta_forecast);

// by confernce   convert theta_final to a simplex using a softmax transformation (using the softmax function)

// convert theta_final to simplex


  

}
