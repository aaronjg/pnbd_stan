//Copyright 2018 Aaron Goodman <aaronjg@stanford.edu>. Licensed under the GPLv3 or later.

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
  real buy_mean=exp(log_buy_mean);
  real buy_var=exp(log_buy_var);
  real die_mean=exp(log_die_mean);
  real die_var=exp(log_die_var);
  
  vector[NC] log_lambda = (log_lambda_raw*buy_var + log_buy_mean);
  vector[NC] log_mu = (log_mu_raw*die_var + log_die_mean);
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
  log_lambda_raw ~ normal(0,1);
  log_mu_raw ~ normal(0,1);

  
  log_buy_mean ~ normal(0,5);
  log_die_mean ~ normal(0,5);
  log_buy_var ~ normal(0,5);
  log_die_var ~ normal(0,5);
  target += likelihood;
}
generated quantities{
  vector [NC] Pactive = exp( p1x .* log_lambda - lambdamu .* t - likelihood);
}
