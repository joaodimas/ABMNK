library(plotly)
library(tseries)
library(vars)

setwd("/Users/jdimas/GitHub/ABMNK/data")
data = read.csv("ABMNK.LAST.GranularData.csv")

firstSim <- data[data$simulation_number == 1,]
firstSim$simulation_number <- NULL
last <- tail(firstSim, 10)

plot_ly(firstSim, x = last$period, y = last$inflation, name = 'inflation', type="scatter", mode = 'lines+markers') %>%
  add_trace(y = last$real_interest_rate, name = 'real interest rate') %>%
  add_trace(y = last$nominal_interest_rate, name = 'nominal interest rate') %>%
  add_trace(y = last$mean_exp_inflation, name = 'expected inflation') %>%
  add_trace(y = last$output_gap, name = 'output gap')

plot_ly(firstSim, x=~period, y=~mean_substitution_strategy, type="scatter", mode="lines")
plot_ly(firstSim, x=~period, y=~consumption, type="scatter", mode="lines")
plot_ly(firstSim, x=~period, y=~mean_real_savings_balance, type="scatter", mode="lines")

plot_ly(firstSim, x=~period, y=~inflation, type="scatter", mode="lines")
print(paste("Inflation is stationary:", adf.test(firstSim$inflation)$p.value <= 0.05))

plot_ly(firstSim, x=~period, y=~nominal_interest_rate, type="scatter", mode="lines")
print(paste("Nominal interest rate is stationary:", adf.test(firstSim$nominal_interest_rate)$p.value <= 0.05))

plot_ly(firstSim, x=~period, y=~output_gap, type="scatter", mode="lines")
print(paste("Output gap is stationary:", adf.test(firstSim$output_gap)$p.value <= 0.05))

plot_ly(firstSim, x=~period, y=~consumption, type="scatter", mode="lines")
print(paste("Consumption stationary:", adf.test(firstSim$consumption)$p.value <= 0.05))


var <- VAR(firstSim[,c("inflation", "output_gap", "nominal_interest_rate")], lag.max=4, ic="AIC")
summary(var)

Amat = diag(3)
Amat[2,1] <- NA
Amat[3,1] <- NA
Amat[3,2] <- NA
# 1 0 0
# NA 1 0
# NA NA 1

svar <- SVAR(var, estmethod = "direct", Amat=Amat, Bmat=NULL, max.iter=1000)
summary(svar)
svar
cor(x=firstSim$nominal_interest_rate, y=firstSim$consumption)
interestrate_inflation <- irf(svar, impulse="nominal_interest_rate", response="inflation", n.ahead=100)
plot(interestrate_inflation)
outputgap_inflation  <- irf(svar, impulse="output_gap", response="inflation")
plot(outputgap_inflation)
interestrate_consumption <- irf(svar, impulse="nominal_interest_rate", response="consumption")
plot(interestrate_consumption)
savings_consumption <- irf(svar, impulse="mean_real_savings_balance", response="consumption")
plot(savings_consumption)


###########
#
# Analyse averages over all simulations
#
###########

setwd("/Users/jdimas/GitHub/ABMNK/data")
fileName <- "ABMNK.2018-02-21T18h35m14s"
data500 = read.csv(paste0(fileName,".GranularData.csv"))
avgData <- aggregate(. ~ period, data=data500, mean)
rm(data500)
avgData$simulation_number <- NULL
write.csv(avgData, file=paste0(fileName,".AverageGranularData.csv"), row.names=FALSE)
tailAvgData <- tail(avgData, 50)
plot_ly(avgData, x = ~period, y = ~inflation, name = 'inflation', type="scatter", mode = 'lines') %>%
  add_trace(y = ~real_interest_rate, name = 'real interest rate') %>%
  add_trace(y = ~nominal_interest_rate, name = 'nominal interest rate') %>%
  add_trace(y = ~mean_exp_inflation, name = 'expected inflation') %>%
  add_trace(y = ~output_gap, name = 'output gap')
