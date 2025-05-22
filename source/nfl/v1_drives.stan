data {
  int<lower=1> drives;   // total drives to evaluate
  int<lower=1> teams;    // number of teams
  int<lower=2> seasons;  // need two for prior in s+1
  
  array[drives] int<lower=1, upper=3> choice; // outcome: 1=turnover, 2=FG, 3=TD
  array[drives] int<lower=1, upper=teams> H;  // vector of home team indices
  array[drives] int<lower=1, upper=teams> A;  // vector of away team indices
  array[drives] int<lower=1, upper=seasons> S; // vector of season indices
}

parameters {
  real alpha; // intercept (baseline offensive advantage)
  ordered[2] cutpoints; // thresholds between outcome categories
  array[teams, seasons] real off_thetas; // team offensive strength by season
  array[teams, seasons] real def_thetas; // team defensive strength by season
  real<lower=0> sigma_off_team;  // team level variance offense
  real<lower=0> sigma_def_team;  // team level variance defense
  real<lower=0> sigma_seasons;   // across season variance within team
  real<lower=0, upper=1> phi_s;  // auto-regressive parameter for season prior
}
  
model {
  // Likelihood
  for (d in 1:drives) {
    real eta = alpha + off_thetas[H[d], S[d]] - def_thetas[A[d], S[d]];
    choice[d] ~ ordered_logistic(eta, cutpoints);
  }
  
  // Priors for main parameters
  alpha ~ normal(0, 1);
  cutpoints ~ normal(0, 2);
  
  // Hyperpriors
  sigma_off_team ~ normal(0, 1);
  sigma_def_team ~ normal(0, 1);
  sigma_seasons ~ normal(0, 0.5);
  phi_s ~ beta(8, 2); // encourages persistence across seasons
  
  // Team-level priors
  for (t in 1:teams) {
    // Initial season prior across teams
    off_thetas[t, 1] ~ normal(0, sigma_off_team);
    def_thetas[t, 1] ~ normal(0, sigma_def_team);
    
    // AR(1) model across seasons
    for (s in 2:seasons) {
      off_thetas[t, s] ~ normal(phi_s * off_thetas[t, s-1], sigma_seasons);
      def_thetas[t, s] ~ normal(phi_s * def_thetas[t, s-1], sigma_seasons);
    }
  }
}
