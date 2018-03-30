//Copyright 2018 Aaron Goodman <aaronjg@stanford.edu>. Licensed under the GPLv3 or later.

data{
  int NC;
  vector[NC] p1x; //use vector rather than int
  vector[NC] tx;
  vector[NC] t;
}
parameters{
  real<lower = 0> r;
  real<lower = 0> alpha;
  real<lower = 0> s;
  real<lower = 0> beta;

  vector[NC] log_lambda_raw;
  vector[NC] log_mu_raw;
}
transformed parameters{
  vector[NC] log_lambda = log_lambda_raw - log(alpha);
  vector[NC] log_mu = log_mu_raw - log(beta);
  vector[NC] likelihood;
  vector[NC] lambdamu = exp(log_lambda) + exp(log_mu);

  for(i in 1:NC){
    real log_lambda_mu = log_sum_exp(log_lambda[i],log_mu[i]);
    
    real part1 = p1x[i] .* log_lambda[i] + log_mu[i] - (lambdamu[i]) .* tx[i] -
      log_lambda_mu;
    real part2 = (p1x[i] + 1) * log_lambda[i] - (lambdamu[i]) * t[i] -
      log_lambda_mu;
    
    likelihood[i] = log_sum_exp(part1,part2);
  }  
}
model{
  target += log_lambda_raw;
  target += log_mu_raw;

  exp(log_lambda_raw) ~ gamma(r,1);
  exp(log_mu_raw) ~ gamma(s,1);

  r ~ lognormal(0,5);
  alpha ~ lognormal(0,5);
  s ~ lognormal(0,5);
  beta ~ lognormal(0,5);

  target += likelihood;  
}

generated quantities{
  real buy_mean = r/alpha;
  real buy_var = r/alpha^2;
  real die_mean = s/beta;
  real die_var = s/beta^2;
  real Pactive[NC];
  for (i in 1:NC){
    Pactive[i] = exp( p1x[i] * log_lambda[i] - (lambdamu[i])*t[i] - likelihood[i]);
  }
}
