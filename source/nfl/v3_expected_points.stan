data {
  int<lower=1> plays;   // total plays to evaluate
  int<lower=1> teams;   // number of teams
  int<lower=1> weeks;   // number of weeks
  
  array[plays] real epa; // outcome: expected points added
  array[plays] int<lower=1, upper=teams> OFF; // offensive team (posteam)
  array[plays] int<lower=1, upper=teams> DEF; // defensive team (defteam)
  array[plays] int<lower=1, upper=teams> H; // home team
  array[plays] int<lower=1, upper=teams> A; // away team
  
  array[plays] int<lower=1, upper=weeks> W; // weeks
}
parameters {
  real alpha;  // home field advantage
  array[teams,weeks] real off_theta_raw; // raw offensive strength
  array[teams,weeks] real def_theta_raw; // raw defensive strength
  real<lower=0> sigma_epa; // play-level variance in epa
  real<lower=0> sigma_off; // across team offensive variance
  real<lower=0> sigma_def; // across team defensive variance
}
transformed parameters {
  array[teams,weeks] real off_theta;
  array[teams,weeks] real def_theta;
  
  // Sum-to-zero constraints for identifiability
  real off_sum = 0;
  real def_sum = 0;
  
  // Calculate sums for centering
  for (t in 1:teams) {
    for (w in 1:weeks) {
      off_sum += off_theta_raw[t,w];
      def_sum += def_theta_raw[t,w];
    }
  }
  
  real off_mean = off_sum / (teams * weeks);
  real def_mean = def_sum / (teams * weeks);
  
  // Apply centering
  for (t in 1:teams) {
    for (w in 1:weeks) {
      off_theta[t,w] = off_theta_raw[t,w] - off_mean;
      def_theta[t,w] = def_theta_raw[t,w] - def_mean;
    }
  }
}
model {
  // Likelihood: play-level model
  for (n in 1:plays) {
    real hfa = 0;
    
    // Add home field advantage if offensive team is home
    if (OFF[n] == H[n]) {
      hfa = alpha;
    }
    
    epa[n] ~ normal(hfa + off_theta[OFF[n],W[n]] - def_theta[DEF[n],W[n]], sigma_epa);
  }
  
  // Priors
  alpha ~ normal(0, 0.5);  // home field advantage prior
  sigma_epa ~ normal(0, 2);  // play-level noise
  sigma_off ~ normal(0, 1);  // offensive team variation
  sigma_def ~ normal(0, 1);  // defensive team variation
  
  // Team strength priors
  for (t in 1:teams) {
    for (w in 1:weeks) {
      off_theta_raw[t,w] ~ normal(0, sigma_off);
      def_theta_raw[t,w] ~ normal(0, sigma_def);
    }
  }
}
