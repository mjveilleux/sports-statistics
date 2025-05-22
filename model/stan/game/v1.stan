data {
  int<lower=1> games;               // total number of games
  int<lower=1> teams;               // number of teams
  int<lower=2> seasons;             // number of seasons (minimum 2 for AR(1))
  array[games] real ep_home;        // expected points for home team
  array[games] real ep_away;        // expected points for away team
  array[games] int<lower=1, upper=teams> H;    // home team indices
  array[games] int<lower=1, upper=teams> A;    // away team indices
  array[games] int<lower=1, upper=seasons> S;  // season indices
}

parameters {
  real alpha;                       // home field advantage
  array[teams, seasons] real off_strength;  // offensive strengths
  array[teams, seasons] real def_strength;  // defensive strengths
  real<lower=0> sigma_games;        // game-level variance
  real<lower=0> sigma_teams_off;    // variance for initial offensive strength
  real<lower=0> sigma_seasons_off;  // variance for season-to-season offense
  real<lower=0> sigma_teams_def;    // variance for initial defensive strength
  real<lower=0> sigma_seasons_def;  // variance for season-to-season defense
  real<lower=0, upper=1> phi;       // AR(1) parameter for season effects
}

model {
  // Define mean expected points for home and away teams
  vector[games] mu_home;
  vector[games] mu_away;
  
  // Populate mean vectors
  for (g in 1:games) {
    mu_home[g] = off_strength[H[g], S[g]] - def_strength[A[g], S[g]] + alpha;
    mu_away[g] = off_strength[A[g], S[g]] - def_strength[H[g], S[g]];
  }
  
  // Vectorized likelihood
  ep_home ~ normal(mu_home, sigma_games);
  ep_away ~ normal(mu_away, sigma_games);
  
  // Team-level priors with AR(1) process across seasons
  for (t in 1:teams) {
    off_strength[t, 1] ~ normal(0, sigma_teams_off);
    def_strength[t, 1] ~ normal(0, sigma_teams_def);
    for (s in 2:seasons) {
      off_strength[t, s] ~ normal(phi * off_strength[t, s-1], sigma_seasons_off);
      def_strength[t, s] ~ normal(phi * def_strength[t, s-1], sigma_seasons_def);
    }
  }
  
  // Priors for hyperparameters
  alpha ~ normal(0, 10);
  sigma_games ~ normal(0, 10);
  sigma_teams_off ~ normal(0, 10);
  sigma_seasons_off ~ normal(0, 10);
  sigma_teams_def ~ normal(0, 10);
  sigma_seasons_def ~ normal(0, 10);
  // phi is uniform(0,1) by default due to bounds
}
