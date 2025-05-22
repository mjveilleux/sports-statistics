data {
  int<lower=1> drives_nbr;
  int<lower=1> weeks_nbr;
  int<lower=1> teams_nbr;
  int<lower=1, upper=weeks_nbr> week[drives_nbr];
  int<lower=1, upper=teams_nbr> posteam_id[drives_nbr];
  int<lower=1, upper=teams_nbr> defteam_id[drives_nbr];
  int<lower=0, upper=1> posteam_hfa[drives_nbr];
  int<lower=0, upper=6> choice[drives_nbr];
}

transformed data {
  int<lower=1, upper=3> y[drives_nbr];  // Transformed outcome (1, 2, 3)
  for (i in 1:drives_nbr) {
    if (choice[i] == 0) y[i] = 1;
    else if (choice[i] == 3) y[i] = 2;
    else if (choice[i] == 6) y[i] = 3;
  }
}

parameters {
  matrix[2, weeks_nbr] alpha;              // Category-specific intercepts (k=2,3) by week
  matrix[weeks_nbr, teams_nbr] off_strength;    // Offensive strengths by week and team
  matrix[weeks_nbr, teams_nbr] def_strength;    // Defensive strengths by week and team
  vector[teams_nbr] off_strength_global;   // Global offensive strengths
  vector[teams_nbr] def_strength_global;   // Global defensive strengths
  matrix[2, weeks_nbr] beta;               // HFA effects by category (k=2,3) and week
  real<lower=0> sigma_off;           // SD for global off strengths
  real<lower=0> sigma_def;           // SD for global def strengths
  real<lower=0> sigma_off_week;      // SD for week-specific off strengths
  real<lower=0> sigma_def_week;      // SD for week-specific def strengths
  real<lower=0> sigma_alpha;         // SD for intercepts
  real<lower=0> sigma_beta;          // SD for HFA effects
}

model {
  // Priors for global team strengths
  for (t in 1:teams_nbr) {
    off_strength_global[t] ~ normal(0, sigma_off);
    def_strength_global[t] ~ normal(0, sigma_def);
  }
  
  // Priors for week-specific team strengths (hierarchical)
  for (w in 1:weeks_nbr) {
    for (t in 1:teams_nbr) {
      off_strength[w, t] ~ normal(off_strength_global[t], sigma_off_week);
      def_strength[w, t] ~ normal(def_strength_global[t], sigma_def_week);
    }
  }
  
  // Priors for intercepts and HFA effects
  for (k in 1:2) {
    for (w in 1:weeks_nbr) {
      alpha[k, w] ~ normal(0, sigma_alpha);
      beta[k, w] ~ normal(0, sigma_beta);
    }
  }
  
  // Hyperpriors
  sigma_off ~ cauchy(0, 2.5);
  sigma_def ~ cauchy(0, 2.5);
  sigma_off_week ~ cauchy(0, 2.5);
  sigma_def_week ~ cauchy(0, 2.5);
  sigma_alpha ~ cauchy(0, 2.5);
  sigma_beta ~ cauchy(0, 2.5);
  
  // Likelihood
  for (i in 1:drives_nbr) {
    vector[3] eta;  // Logits for categories 1, 2, 3
    eta[1] = 0;     // Reference category (choice = 0)
    for (k in 1:2) {  // Categories 2 (3 points) and 3 (6 points)
      eta[k + 1] = alpha[k, week[i]] +
                   off_strength[week[i], posteam_id[i]] -
                   def_strength[week[i], defteam_id[i]] +
                   beta[k, week[i]] * posteam_hfa[i];
    }
    y[i] ~ categorical_logit(eta);
  }
}

generated quantities {
  // Log-likelihood for model comparison
  vector[drives_nbr] log_lik;
  
  for (i in 1:drives_nbr) {
    vector[3] eta;
    eta[1] = 0;
    for (k in 1:2) {
      eta[k + 1] = alpha[k, week[i]] +
                   off_strength[week[i], posteam_id[i]] -
                   def_strength[week[i], defteam_id[i]] +
                   beta[k, week[i]] * posteam_hfa[i];
    }
    log_lik[i] = categorical_logit_lpmf(y[i] | eta);
  }
}