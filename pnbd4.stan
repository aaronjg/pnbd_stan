//Copyright 2018 Aaron Goodman <aaronjg@stanford.edu>. Licensed under the GPLv3 or later.
functions {
  real gamma_shape(real mean, real variance){
    return exp(2*mean^2 - variance);
  }
  real gamma_scale(real mean, real variance){
    return  exp(mean-variance);
  }
}
data{
  int NC;
  vector[NC] p1x; //use vector rather than int
  vector[NC] tx;
  vector[NC] t;
}
parameters{
  real log_buy_mean;
  real log_buy_var;
  real log_die_mean;
  real log_die_var;

  vector[NC] log_lambda_raw;
  vector[NC] log_mu_raw;
}
transformed parameters{
  vector[NC] likelihood;
  vector[NC] lambdamu;

  vector[NC] log_lambda;
  vector[NC] log_mu;
  real buy_mean = exp(log_buy_mean);
  real buy_var = exp(log_buy_var);
  real die_mean = exp(log_die_mean);
  real die_var = exp(log_die_var);
  real r = gamma_shape(log_buy_mean,log_buy_var);
  real alpha = gamma_scale(log_buy_mean,log_buy_var);
  real s = gamma_shape(log_die_mean,log_die_var);
  real beta = gamma_scale(log_die_mean,log_die_var);  
    
  for(i in 1:NC){
    real log_lambda_mu;
    log_lambda[i] = log_sum_exp(log_lambda_raw[i]+ log_buy_var, log_buy_mean);
    log_mu[i] = log_sum_exp(log_mu_raw[i] + log_die_var,log_die_mean);
    log_lambda_mu = log_sum_exp(log_lambda[i],log_mu[i]);
    lambdamu[i] = exp(log_lambda[i]) + exp(log_mu[i]);
    {
      real part1 = p1x[i] .* log_lambda[i] + log_mu[i] - (lambdamu[i]) .* tx[i] -
        log_lambda_mu;
      real part2 = (p1x[i] + 1) * log_lambda[i] - (lambdamu[i]) * t[i] -
        log_lambda_mu;
      
      likelihood[i] = log_sum_exp(part1,part2);
    }
  }
}
model{
  target += log_lambda_raw;
  target += log_mu_raw;
  target += NC * (log_buy_var+log_die_var);

  target += 2*log_buy_mean - 3*log_buy_var;
  target += 2*log_die_mean - 3*log_die_var;  

  
  exp(log_lambda) ~ gamma(r,alpha);
  exp(log_mu) ~ gamma(s,beta);

  r ~ lognormal(0,5);
  alpha ~ lognormal(0,5);
  s ~ lognormal(0,5);
  beta ~ lognormal(0,5);

  target += likelihood;  
}

generated quantities{
  real Pactive[NC];
  for (i in 1:NC){
    Pactive[i] = exp( p1x[i] * log_lambda[i] - (lambdamu[i])*t[i] - likelihood[i]);
  }
}
