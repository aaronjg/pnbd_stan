#Copyright 2018 Aaron Goodman <aaronjg@stanford.edu>. Licensed under the GPLv3 or later.


# customers is a data frame with
# lambda
# mu
# pactive
simulatePurchaseMarginals <- function(customers, time){
  n <- nrow(customers)
  alive <- runif(n) < customers$Pactive
  n.alive <- sum(customers$alive)
  raw.death.time <- rexp(n, customers$mu)
  death.time <- ifelse(alive,
                ifelse(raw.death.time > time, time, raw.death.time),
                0)
  customers$death.time <- death.time
  customers$purchase.count <- rpois(n,customers$lambda * death.time)
  return(customers)
}

simulatePurchases <- function(customers){
  customers %>% group_by(custid)%>% do(data.frame(time = sort(runif(.$purchase.count)) * .$death.time)) %>% ungroup()
}

posteriorStats <- function(i, summarized,posterior){
  customers <- cbind(summarized,posterior.draw(posterior,i))
  simulated <- simulatePurchaseMarginals(customers,39)
  weekly <- table(cut(simulatePurchases(simulated)$time,0:39))
  customer.stat <- data.frame(type = 'customer', id = simulated$custid,
                              value = simulated$purchase.count)
  weekly.stat <- data.frame(type = 'weekly', id = 1:39, value= as.numeric(weekly))
  return(rbind(customer.stat,weekly.stat))
}
