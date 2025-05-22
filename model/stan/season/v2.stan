data {
  int<lower=1> games;   // total games to evaluate
  int<lower=1> teams;            // number of teams
  int<lower=2> seasons; // need two for prior in s+1
  
  array[games] real h_point_diff; // outcome: point differential (ps - pa)
  
  array[games] int<lower=1, upper=teams> H; // vector of home team indices
  array[games] int<lower=1, upper=teams> A; // vector of away team indices
  array[games] int<lower=1, upper=seasons> S; // vector of season indices
}

parameters {
  real alpha; // intercept (HFA)
  array[teams, seasons] real thetas; // team strength coefficient for each team-season
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
