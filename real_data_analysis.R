while (!require("plotly")) install.packages("plotly")
while (!require("tseries")) install.packages("tseries")
while (!require("vars")) install.packages("vars")

rm(list = ls())
setwd("/Users/jdimas/GitHub/ABMNK/real_data")

# TODO: add all new variables
data <- read.csv("data.csv", colClasses=c("Date", "numeric", "numeric", "numeric", "numeric", "numeric"))
data$real_interest_rate <- data$nominal_interest_rate - data$exp_inflation
after1995 <- na.omit(data[data$date > as.Date("1995-09-30"),])
# after1995$nominal_interest_rate = as.numeric(scale(after1995$nominal_interest_rate))
# after1995$inflation = as.numeric(scale(after1995$inflation))
# after1995$output_gap = as.numeric(scale(after1995$output_gap))
# after1995$exp_inflation = as.numeric(scale(after1995$exp_inflation))
# after1995$real_interest_rate = as.numeric(scale(after1995$real_interest_rate))
plot_ly(after1995, x=~date, y = ~(inflation+1)^3-1, name = 'quarterly inflation', type="scatter", mode = 'lines+markers') %>%
  add_trace(y = ~real_interest_rate, name = 'real yearly interest rate') %>%
  add_trace(y = ~exp_inflation, name = 'expected inflation') %>%
  add_trace(y = ~output_gap, name = 'output gap')

plot_ly(after1995, x=~date, y=~inflation, type="scatter", mode="lines")
print(paste("Inflation is stationary:", adf.test(after1995$inflation)$p.value <= 0.05))

plot_ly(after1995, x=~date, y=~nominal_interest_rate, type="scatter", mode="lines")
print(paste("Nominal interest rate is stationary:", adf.test(after1995$nominal_interest_rate)$p.value <= 0.05))

plot_ly(after1995, x=~date, y=~output_gap, type="scatter", mode="lines")
print(paste("Output gap is stationary:", adf.test(after1995$output_gap)$p.value <= 0.05))


var <- VAR(after1995[,c("inflation", "output_gap", "nominal_interest_rate", "exp_inflation")], lag.max=4, ic="AIC")
var <- VAR(after1995[,c("inflation", "output_gap", "nominal_interest_rate", "exp_inflation")], lag.max=4, ic="AIC")
summary(var)

Amat = diag(4)
Amat[2,1] <- NA
Amat[3,1] <- NA
Amat[3,2] <- NA
Amat[4,1] <- NA
Amat[4,2] <- NA
Amat[4,3] <- NA
# 1 0 0 0
# NA 1 0 0
# NA NA 1 0
# NA NA NA 1 
svar <- SVAR(var, estmethod = "direct", Amat=Amat, Bmat=NULL, max.iter=1000)
summary(svar)
svar
interestrate_inflation <- irf(svar, impulse="nominal_interest_rate", response="inflation", n.ahead=100)
plot(interestrate_inflation)
outputgap_inflation  <- irf(svar, impulse="output_gap", response="nominal_interest_rate")
plot(outputgap_inflation)
inflation_interestrate <- irf(svar, impulse="inflation", response="nominal_interest_rate", n.ahead=100)
plot(inflation_interestrate)
exp_inflation_interestrate <- irf(svar, impulse="exp_inflation", response="nominal_interest_rate", n.ahead=100)
plot(exp_inflation_interestrate)
interestrate_exp_inflation <- irf(svar, impulse="nominal_interest_rate", response="exp_inflation", n.ahead=100)
plot(interestrate_exp_inflation)
