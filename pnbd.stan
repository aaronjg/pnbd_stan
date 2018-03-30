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

  vector[NC] log_lambda;
  vector[NC] log_mu;
}

transformed parameters{
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
  target += log_lambda;
  target += log_mu;

  exp(log_lambda) ~ gamma(r,alpha);
  exp(log_mu) ~ gamma(s,beta);

  r ~ normal(0,1);
  alpha ~ normal(0,1);
  s ~ normal(0,1);
  beta ~ normal(0,1);

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

