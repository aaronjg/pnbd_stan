//Copyright 2018 Aaron Goodman <aaronjg@stanford.edu>. Licensed under the GPLv3 or later.

#include /pnbd_data.stan
parameters{
  real<lower = 0> r;
  real<lower = 0> alpha;
  real<lower = 0> s;
  real<lower = 0> beta;

  vector<lower = 0>[NC] lambda;
  vector<lower = 0>[NC] mu;
}

transformed parameters{
  vector[NC] likelihood;
  vector[NC] lambdamu = lambda + mu;
  vector[NC] log_lambda = log(lambda);
  vector[NC] log_mu = log(mu);
#include /pnbdlikelihoodloop.stan
}

model{
  lambda ~ gamma(r,alpha);
  mu ~ gamma(s,beta);

  r ~ normal(1,1);
  alpha ~ normal(1,1);
  s ~ normal(1,1);
  beta ~ normal(1,1);

  target += likelihood;
}
generated quantities{
#include /pnbd_generatedquantities.stan
}
