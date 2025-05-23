data {
  int<lower=1> N;   // total plays to evaluate
  int<lower=1> teams;   // number of teams
  // int<lower=2> seasons; // need two for prior in s+1
  
  array[N] real epa; // outcome: expected points added
  
  array[N] int<lower=1, upper=teams> H; // vector of home team indices
  array[N] int<lower=1, upper=teams> A; // vector of away team indices
  // array[games] int<lower=1, upper=seasons> S; // vector of season indices
}

parameters {
  array[teams] real alpha; // intercept (HFA)
  array[teams] real thetas; // team strength coefficient for each team-season
  real<lower=0> sigma_epa; // play-level variance in epa
  real<lower=0> sigma_teams; // across team variance before season
  // real<lower=0> sigma_seasons; // across season variance within team
  // real<lower=0, upper=1> phi_s; // auto-regressive parameter for season prior
}

model {
  // game-level model
  for (n in 1:N) {
    epa[n] ~ normal(alpha[H[n]] + thetas[H[n]] - thetas[A[n]], sigma_epa);
  }
  
  // team-level priors
  for (t in 1:teams) {
    // initial season prior across teams
    thetas[t] ~ normal(0, sigma_teams);
  }
}
