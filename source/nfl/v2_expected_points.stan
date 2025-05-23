data {
  int<lower=1> N;   // total plays to evaluate
  int<lower=1> teams;   // number of teams
  array[N] real epa; // outcome: expected points added
  array[N] int<lower=1, upper=teams> H; // vector of home team indices
  array[N] int<lower=1, upper=teams> A; // vector of away team indices
}

parameters {
  real alpha;  // home field advantage (single parameter)
  array[teams] real thetas_raw; // raw team strength coefficients
  real<lower=0> sigma_epa; // play-level variance in epa
  real<lower=0> sigma_teams; // across team variance
}

transformed parameters {
  array[teams] real thetas;
  
  // Sum-to-zero constraint for identifiability
  real theta_mean = mean(thetas_raw);
  for (t in 1:teams) {
    thetas[t] = thetas_raw[t] - theta_mean;
  }
}

model {
  // Likelihood: game-level model
  for (n in 1:N) {
    epa[n] ~ normal(alpha + thetas[H[n]] - thetas[A[n]], sigma_epa);
  }
  
  // Priors
  alpha ~ normal(0, 1);  // home field advantage prior
  sigma_epa ~ normal(0, 1);  // half-normal due to lower bound
  sigma_teams ~ normal(0, 1);  // half-normal due to lower bound
  
  // Team strength priors
  for (t in 1:teams) {
    thetas_raw[t] ~ normal(0, sigma_teams);
  }
}

generated quantities {
  // Posterior predictive checks
  array[N] real epa_rep;
  for (n in 1:N) {
    epa_rep[n] = normal_rng(alpha + thetas[H[n]] - thetas[A[n]], sigma_epa);
  }
}
