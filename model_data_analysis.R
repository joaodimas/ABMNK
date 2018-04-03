# Prepare the environment ----
library(plotly)
library(tseries)
library(vars)
rm(list = ls())

# Parameters ----
dataFolder <- "20180403"
scenario <- 5
experiment <- 5


fileName <- paste0("ABMNK.LAST[Sce_",scenario,"][Exp_",experiment,"][Sim_1]GranularData")
fileName2 <- paste0("ABMNK.LAST[Sce_",scenario,"][Exp_",experiment,"][Sim_2]GranularData")

# Import and prepare data ----
setwd(paste0("/Users/jdimas/GitHub/ABMNK/",dataFolder,"_data"))
data <- read.csv(paste0(fileName,".csv"))
data$simulation_number <- NULL
data$experiment <- NULL

data2 <- read.csv(paste0(fileName2,".csv"))
data2$experiment <- NULL
data2$simulation_number <- NULL


# Exploratory ----

cor(x=data$nominal_interest_rate, y=data$consumption)

plot_ly(data, x = ~period, y = ~inflation, name = 'inflation', type="scatter", mode = 'lines') %>%
  add_trace(y = ~real_interest_rate, name = 'real interest rate') %>%
  add_trace(y = ~nominal_interest_rate, name = 'nominal interest rate') %>%
  add_trace(y = ~mean_exp_inflation, name = 'expected inflation') %>%
  add_trace(y = ~output_gap, name = 'output gap')

plot_ly(data, x=~period, y=~mean_substitution_strategy, type="scatter", mode="lines")
plot_ly(data, x=~period, y=~consumption, type="scatter", mode="lines")
plot_ly(data, x=~period, y=~mean_real_savings_balance, type="scatter", mode="lines")

plot_ly(data, x=~period, y=~inflation, type="scatter", mode="lines")
print(paste("Inflation is stationary:", adf.test(data$inflation)$p.value <= 0.05))

plot_ly(data, x=~period, y=~nominal_interest_rate, type="scatter", mode="lines")
print(paste("Nominal interest rate is stationary:", adf.test(data$nominal_interest_rate)$p.value <= 0.05))

plot_ly(data, x=~period, y=~output_gap, type="scatter", mode="lines")
print(paste("Output gap is stationary:", adf.test(data$output_gap)$p.value <= 0.05))

plot_ly(data, x=~period, y=~consumption, type="scatter", mode="lines")
print(paste("Consumption stationary:", adf.test(data$consumption)$p.value <= 0.05))

# VAR ----
var <- VAR(data[,c("inflation", "output_gap", "nominal_interest_rate")], lag.max=4, ic="AIC")

# SVAR ----
Amat = diag(3)
Amat[2,1] <- NA
Amat[3,1] <- NA
Amat[3,2] <- NA
svar <- SVAR(var, estmethod = "direct", Amat=Amat, Bmat=NULL, max.iter=1000)

# IRF ----
irf.interestrate.inflation <- irf(svar, impulse="nominal_interest_rate", response="inflation", n.ahead=100, cumulative = TRUE)
irf.interestrate.inflation.df <- data.frame(irf.interestrate.inflation$irf[[1]], irf.interestrate.inflation$Upper[[1]], irf.interestrate.inflation$Lower[[1]])
# irf.interestrate.inflation.cum <- irf(svar, impulse="nominal_interest_rate", response="inflation", n.ahead=100, cumulative = TRUE)
# irf.interestrate.inflation.cum.df <- data.frame(irf.interestrate.inflation.cum$irf[[1]], irf.interestrate.inflation.cum$Upper[[1]], irf.interestrate.inflation.cum$Lower[[1]])
# irf.interestrate.output_gap <- irf(svar, impulse="nominal_interest_rate", response="output_gap", n.ahead=100)
# irf.interestrate.output_gap.cum <- irf(svar, impulse="nominal_interest_rate", response="output_gap", n.ahead=100, cumulative = TRUE)
# irf.inflation.interestrate <- irf(svar, impulse="inflation", response="nominal_interest_rate", n.ahead=100)
# irf.inflation.interestrate.cum <- irf(svar, impulse="inflation", response="nominal_interest_rate", n.ahead=100, cumulative = TRUE)
# plot(irf.inflation.interestrate.cum)
# irf.outputgap.inflation  <- irf(svar, impulse="output_gap", response="inflation")
# irf.outputgap.inflation.cum  <- irf(svar, impulse="output_gap", response="inflation", n.ahead=100, cumulative = TRUE)
# irf.interestrate.consumption <- irf(svar, impulse="nominal_interest_rate", response="consumption", n.ahead=100)
# irf.interestrate.consumption.cum <- irf(svar, impulse="nominal_interest_rate", response="consumption", n.ahead=100, cumulative = TRUE)
# irf.savings.consumption <- irf(svar, impulse="mean_real_savings_balance", response="consumption", n.ahead=100)
# irf.savings.consumption.cum <- irf(svar, impulse="mean_real_savings_balance", response="consumption", n.ahead=100, cumulative = TRUE)

var2 <- VAR(data2[,c("inflation", "output_gap", "nominal_interest_rate")], lag.max=4, ic="AIC")
Amat = diag(3)
Amat[2,1] <- NA
Amat[3,1] <- NA
Amat[3,2] <- NA
svar2 <- SVAR(var2, estmethod = "direct", Amat=Amat, Bmat=NULL, max.iter=1000)
irf2.interestrate.inflation <- irf(svar2, impulse="nominal_interest_rate", response="inflation", n.ahead=100, cumulative = TRUE)
irf2.interestrate.inflation.df <- data.frame(irf2.interestrate.inflation$irf[[1]], irf2.interestrate.inflation$Upper[[1]], irf2.interestrate.inflation$Lower[[1]])

plot_ly(irf.interestrate.inflation.df, y=~inflation, name="sim 1", type="scatter", mode="lines") %>%
  add_trace(data=irf2.interestrate.inflation.df, y = ~inflation, name = 'sim 2')

# Import a second data set for comparison ----
