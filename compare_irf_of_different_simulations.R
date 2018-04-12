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
fileName3 <- paste0("ABMNK.LAST[Sce_1][Exp_18][Sim_1]GranularData")

# Import and prepare data ----
setwd(paste0("/Users/jdimas/GitHub/ABMNK/",dataFolder,"_data"))
data <- read.csv(paste0(fileName,".csv"))
data$simulation_number <- NULL
data$experiment <- NULL

data2 <- read.csv(paste0(fileName2,".csv"))
data2$experiment <- NULL
data2$simulation_number <- NULL

data3 <- read.csv(paste0(fileName3,".csv"))
data3$experiment <- NULL
data3$simulation_number <- NULL

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
irf.interestrate.inflation <- irf(svar, impulse="nominal_interest_rate", response="inflation", n.ahead=500)
irf.interestrate.inflation.df <- data.frame(irf.interestrate.inflation$irf[[1]], irf.interestrate.inflation$Upper[[1]], irf.interestrate.inflation$Lower[[1]])

var2 <- VAR(data2[,c("inflation", "output_gap", "nominal_interest_rate")], lag.max=4, ic="AIC")
Amat = diag(3)
Amat[2,1] <- NA
Amat[3,1] <- NA
Amat[3,2] <- NA
svar2 <- SVAR(var2, estmethod = "direct", Amat=Amat, Bmat=NULL, max.iter=1000)
irf2.interestrate.inflation <- irf(svar2, impulse="nominal_interest_rate", response="inflation", n.ahead=500)
irf2.interestrate.inflation.df <- data.frame(irf2.interestrate.inflation$irf[[1]], irf2.interestrate.inflation$Upper[[1]], irf2.interestrate.inflation$Lower[[1]])

periodsAhead <- 100
plot_ly(head(irf.interestrate.inflation.df,periodsAhead), y=~inflation, name="sim 1", type="scatter", mode="lines") %>%
  add_trace(data=head(irf2.interestrate.inflation.df,periodsAhead), y = ~inflation, name = 'sim 2')

mean_irf1and2.df <- data.frame(inflation = (irf.interestrate.inflation.df$inflation+irf2.interestrate.inflation.df$inflation)/2)
plot_ly(head(mean_irf1and2.df,periodsAhead), y=~inflation, name="sim 1", type="scatter", mode="lines")

var3 <- VAR(data3[,c("inflation", "output_gap", "nominal_interest_rate")], lag.max=4, ic="AIC")
Amat = diag(3)
Amat[2,1] <- NA
Amat[3,1] <- NA
Amat[3,2] <- NA
svar3 <- SVAR(var3, estmethod = "direct", Amat=Amat, Bmat=NULL, max.iter=1000)
irf3.interestrate.inflation <- irf(svar3, impulse="nominal_interest_rate", response="inflation", n.ahead=500)
irf3.interestrate.inflation.df <- data.frame(irf3.interestrate.inflation$irf[[1]], irf3.interestrate.inflation$Upper[[1]], irf3.interestrate.inflation$Lower[[1]])

periodsAhead <- 100
plot_ly(head(irf3.interestrate.inflation.df,periodsAhead), y=~inflation, name="sim 1", type="scatter", mode="lines")