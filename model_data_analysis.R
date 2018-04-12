# Prepare the environment ----
library(plotly)
library(tseries)
library(vars)
rm(list = ls())

# Parameters ----
dataFolder <- "20180403"
scenario <- 1
experiment <- 18
simulation <- 1


fileName <- paste0("ABMNK.LAST[Sce_",scenario,"][Exp_",experiment,"][Sim_",simulation,"]GranularData.csv")

# Import and prepare data ----
setwd(paste0("../ABMNK_model_output/",dataFolder,"_data"))
data <- read.csv(fileName)
data$simulation_number <- NULL
data$experiment <- NULL

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
var <- VAR(data[,c("inflation", "output_gap", "consumption", "real_wage_rate", "nominal_interest_rate", "mean_real_savings_balance")], lag.max=10, ic="AIC")

# SVAR ----
Amat = diag(var$K)
Amat[lower.tri(Amat)] <- NA
svar <- SVAR(var, estmethod = "direct", Amat=Amat, Bmat=NULL, max.iter=1000)

# IRF ----
irf.interestrate.inflation <- irf(svar, impulse="nominal_interest_rate", response="inflation", n.ahead=50)
irf.interestrate.inflation.df <- data.frame(irf.interestrate.inflation$irf[[1]], irf.interestrate.inflation$Upper[[1]], irf.interestrate.inflation$Lower[[1]])
plot_ly(irf.interestrate.inflation.df, y=~inflation, type="scatter", mode="lines")
