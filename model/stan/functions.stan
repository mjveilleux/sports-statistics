vector prob_best_rng(vector beta) {
  int P = size(beta);
  real M = max(beta);
  real N = 0.0;
  vector[P] B = zeros_vector(P);
  for (p in 1:P) {
    if (beta[p] == M) {
      B[p] += 1;
      N += 1;
    }
  }
  B = B/N;
  return B;
}
 


vector prob_best_rng(vector beta) {
  int P = size(beta);
  real M = max(beta);
  real N = 0.0;
  vector[P] B = zeros_vector(P);
  for (p in 1:P) {
    if (beta[p] == M) {
      B[p] += 1;
      N += 1;
    }
  }
  B = B/N;
  return B;
}
  

