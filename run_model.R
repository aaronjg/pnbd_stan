#Copyright 2018 Aaron Goodman <aaronjg@stanford.edu>. Licensed under the GPLv3 or later.
library(dplyr)
library(rstan)
source("simulate_data.R")
options(mc.cores = parallel::detectCores())

data <- read.table("CDNOW_sample.txt",col.names=c("rawcust","custid","date","qty","value")) %>% mutate(date=as.Date(as.character(date),format="%Y%m%d"))

#data <- read.table("CDNOW_master.txt",col.names=c("custid","date","qty","value")) %>% mutate(date=as.Date(as.character(date),format="%Y%m%d"))

end.date <- max(data$date)

end.date <- as.Date("1997-09-30")
summarized <- data %>% filter(date <= as.Date("1997-09-30")) %>% group_by(custid) %>% summarize(p1x=length(unique(date))-1,t = as.numeric(end.date - min(date))/7, tx= as.numeric(max(date) - min(date))/7)

repeat.transactions <- data %>% group_by(custid) %>% do(data.frame(date = tail(unique(.$date),-1))) %>% ungroup()

holdout <- data %>% filter(date > as.Date("1997-09-30"))%>% group_by(custid) %>% summarize(holdout.count=length(unique(date)))

Sys.setenv(R_MAKEVARS_USER=file.path(getwd(),"stan_makevars"))
stan.data <- as.list(summarized)
stan.data$NC <- nrow(summarized)

#model <- stan_model("pnbd__adjust.stan")
models <- list()
results <- list()
model.files <- c("pnbd_notransform","pnbd","pnbd_hypermean","pnbd_scale_adjust","pnbd_mean_var_adjust")


for(i in model.files){
    if(!is.null(results[[i]]))
        next
    models[[i]] <- stan_model(paste0(i,".stan"))
    results[[i]] <- sampling(models[[i]],stan.data,chains=2,iter=1000)
}

save.image("out/image.rdata")
#customer by date and customer by time matrices
#slide 3-5
#Slide 139 (p168)
print(out,pars=c('buy_mean','buy_var','die_mean','die_var'),use_cache=FALSE)

print(results[[2]],pars=c('r','alpha','s','beta','lp__'),use_cache=FALSE)

print(results[[5]],pars=c('r','alpha','s','beta','log_lambda[1]','log_lambda[157]','log_mu[1]','log_mu[157]','lp__'),use_cache=FALSE)

pairs(results[[2]],pars=c('r','alpha','s','beta','log_lambda[157]','log_mu[157]'))

pairs(results[[2]],pars=c('log_buy_a','log_buy_b','log_die_a','log_die_b'))
traceplot(results[[1]],pars=c('log_buy_a','log_buy_b','log_die_a','log_die_b'))
traceplot(results[[2]],pars=c('r','alpha','s','beta','lp__'))

extracted <- extract(out,pars=c('r','alpha','s','beta','log_buy_a','log_buy_b','log_die_a','log_die_b'))

print(out,pars=c('log_lambda[1]','log_lambda[2]','log_lambda[100]'),use_cache=F)

posterior.draw <- function(posterior,i){
  data.frame(lambda = exp(posterior$log_lambda[i,]),
             mu = exp(posterior$log_mu[i,]),
             likelihood = posterior$likelihood[i,],
             Pactive = posterior$Pactive[i,]
             )
}


#simulate data from posterior draws
predictive.check <- data.frame(draw=1:100) %>% group_by(draw) %>% do(posteriorStats(.$draw,summarized,posterior)) %>% ungroup()

segmented <- summarized %>%
  mutate(recency.bucket = as.integer(cut(t-tx,seq(0,40,5))),
         p1x.bucket = as.integer(cut(p1x,c(0:4,Inf),include.lowest=TRUE)))

#segment customers by frequency and recency
rfm <- segmented %>%
  left_join(holdout) %>%
  mutate(holdout.count = ifelse(is.na(holdout.count),0,holdout.count)) %>%
  group_by(recency.bucket,p1x.bucket) %>% summarize(n=n(), tot.count = sum(holdout.count),avg.count = mean(holdout.count))

rfm.predicted <- predictive.check %>% filter(type=='customer') %>% rename(custid=id) %>% merge(segmented) %>%   group_by(recency.bucket,p1x.bucket) %>% summarize(avg.count = mean(value))

ggplot(rfm,aes(x=p1x.bucket,y=recency.bucket, fill = avg.count))+geom_tile()
ggplot(rfm.predicted,aes(x=p1x.bucket,y=recency.bucket, fill = avg.count))+geom_tile()

weeks <- as.numeric(repeat.transactions$date - min(repeat.transactions$date))/7
predicted.weeks <- predictive.check %>% filter(type=='weekly') %>% group_by(id) %>% summarize(median = median(value), low = quantile(value,0.025), high = quantile(value, 0.975))

ggplot(data.frame(week=1:max(weeks),count=as.numeric(table(cut(weeks,0:max(weeks),include.lowest=TRUE)))),aes(x=week,y=count))+geom_point()+geom_line() +
  geom_line(data = predicted.weeks, aes(x=id+(end.date-min(data$date))/7, y=median),color='red')  +
  geom_line(data = predicted.weeks,aes(x=id+(end.date-min(data$date))/7, y=low),color='blue')+
  geom_line(data = predicted.weeks,aes(x=id+(end.date-min(data$date))/7, y=high),color='blue')

#ggplot(data = predicted.weeks, aes(x=id+(end.date-min(data$date))/7, ymin=low,ymax=high))+geom_ribbon(color='blue',fill='blue',alpha=.1)


#posterior <- extract(out,c('log_lambda','log_mu','Pactive','likelihood'))
