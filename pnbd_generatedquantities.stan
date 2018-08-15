  real buy_mean = r/alpha;
  real buy_var = r/alpha^2;
  real die_mean = s/beta;
  real die_var = s/beta^2;
  real Pactive[NC];
  for (i in 1:NC){
    Pactive[i] = exp( p1x[i] * log_lambda[i] - (lambdamu[i])*t[i] - likelihood[i]);
  }  

