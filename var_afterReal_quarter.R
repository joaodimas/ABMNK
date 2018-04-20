# Prepare the environment and import data ----
while (!require("plotly")) install.packages("plotly")
while (!require("tseries")) install.packages("tseries")
while (!require("vars")) install.packages("vars")
while (!require("strucchange")) install.packages("strucchange")
while (!require("ecm")) install.packages("ecm")
while (!require("x12")) install.packages("x12")
while (!require("seasonal")) install.packages("seasonal")
while (!require("lubridate")) install.packages("lubridate")
while (!require("forecast")) install.packages("forecast")
while (!require("papeR")) install.packages("papeR")
rm(list = ls())
source("util.R")

VAR_1A = TRUE
VAR_1B = TRUE
VAR_2A = TRUE
VAR_2B = TRUE

real_data_afterReal_quarter <- read.csv("real_data/real_data_afterReal_quarter.csv", row.names="date", colClasses = c("date"="Date"))

###########
# VAR 1A e 1B: Output Gap, inflation and interest rate in two different ordering. ----
###########

# VAR 1A: "nominal_interest_rate", "output_gap", "inflation_adj" = Stable, no serial correlation, initial hump in inflation's dynamic response ----
if(VAR_1A) {
  var1.data <- na.omit(real_data_afterReal_quarter[,c("nominal_interest_rate", "output_gap", "inflation_adj")])
  print(VARselect(var1.data, lag.max = 8)$selection)
  # AIC: 2 lags
  var1 <- VAR(var1.data, p=2, type="const")
  checkVARStability(var1)
  # VAR stable!
  checkVARSerialCorr(var1)
  # No serial correlation!
  checkVARHeteroskedasticity(var1)
  # We detected heteroskedasticity. What should I do?
  checkVARErrorNormality(var1)
  # Errors are not normally distributed. What should I do?
  
  # Generate orthogonal impulse responses (Cholesky decomposition), shock of 1 unit.
  var1.irf.nominal_interest_rate.inflation_adj<- irf(var1, impulse="nominal_interest_rate", response="inflation_adj", n.ahead=20, boot = TRUE)
  plotIRF(var1.irf.nominal_interest_rate.inflation_adj)
  var1.irf.nominal_interest_rate.output_gap <- irf(var1, impulse="nominal_interest_rate", response="output_gap", n.ahead=20, boot = TRUE)
  plotIRF(var1.irf.nominal_interest_rate.output_gap, yAxisDTick = 0.0015)
  var1.irf.output_gap.nominal_interest_rate  <- irf(var1, impulse="output_gap", response="nominal_interest_rate", n.ahead=20, boot=TRUE)
  plotIRF(var1.irf.output_gap.nominal_interest_rate)
  var1.irf.inflation_adj.nominal_interest_rate <- irf(var1, impulse="inflation_adj", response="nominal_interest_rate", n.ahead=20, boot=TRUE)
  plotIRF(var1.irf.inflation_adj.nominal_interest_rate)
}

# VAR 1B: "output_gap", "inflation_adj", "nominal_interest_rate" = Stable, no serial correlation ----
if(VAR_1B) {
  var1B.data <- na.omit(real_data_afterReal_quarter[,c("output_gap", "inflation_adj", "nominal_interest_rate")])
  print(VARselect(var1B.data, lag.max = 8)$selection)
  # AIC: 2 lags
  var1B <- VAR(var1B.data, p=2, type="const")
  checkVARStability(var1B)
  # VAR stable!
  checkVARSerialCorr(var1B)
  # No serial correlation!
  checkVARHeteroskedasticity(var1B)
  # We detected heteroskedasticity. What should I do?
  checkVARErrorNormality(var1B)
  # Errors are not normally distributed. What should I do?
  
  # Generate orthogonal impulse responses (Cholesky decomposition), shock of 1 unit.
  var1B.irf.nominal_interest_rate.inflation_adj<- irf(var1B, impulse="nominal_interest_rate", response="inflation_adj", n.ahead=20, boot = TRUE)
  plotIRF(var1B.irf.nominal_interest_rate.inflation_adj, impulseName = "Interest Rate", responseName = "Inflation", yAxisDTick = 0.002)
  var1B.irf.nominal_interest_rate.output_gap <- irf(var1B, impulse="nominal_interest_rate", response="output_gap", n.ahead=20, boot = TRUE)
  plotIRF(var1B.irf.nominal_interest_rate.output_gap)
  var1B.irf.output_gap.nominal_interest_rate  <- irf(var1B, impulse="output_gap", response="nominal_interest_rate", n.ahead=20, boot=TRUE)
  plotIRF(var1B.irf.output_gap.nominal_interest_rate, yAxisDTick = 0.005)
  var1B.irf.inflation_adj.nominal_interest_rate <- irf(var1B, impulse="inflation_adj", response="nominal_interest_rate", n.ahead=20, boot=TRUE)
  plotIRF(var1B.irf.inflation_adj.nominal_interest_rate, yAxisDTick = 0.005)
}


###########
# VAR 2A e 2B: GDP growth, inflation and interest rate in two different ordering. ----
###########


# VAR 2A: "nominal_interest_rate", "rgdp_growth_adj", "inflation_adj" = Stable, detected serial correlation ----
# Inflation is going up after a shock to interest rate; interest rate is going up after a shock to growth.
if(VAR_2A) {
  var2A.data <- na.omit(real_data_afterReal_quarter[,c("nominal_interest_rate", "rgdp_growth_adj", "inflation_adj")])
  print(VARselect(var2A.data, lag.max = 8)$selection)
  # AIC: 2 lags
  var2A <- VAR(var2A.data, p=2, type="const")
  checkVARStability(var2A)
  # VAR stable!
  checkVARSerialCorr(var2A)
  # Detected correlation!
  
  var2A.irf.nominal_interest_rate.inflation_adj <- irf(var2A, impulse="nominal_interest_rate", response="inflation_adj", n.ahead=20, boot = TRUE)
  plotIRF(var2A.irf.nominal_interest_rate.inflation_adj)
  var2A.irf.nominal_interest_rate.rgdp_growth_adj <- irf(var2A, impulse="nominal_interest_rate", response="rgdp_growth_adj", n.ahead=20, boot = TRUE)
  plotIRF(var2A.irf.nominal_interest_rate.rgdp_growth_adj)
  var2A.irf.rgdp_growth_adj.nominal_interest_rate  <- irf(var2A, impulse="rgdp_growth_adj", response="nominal_interest_rate", n.ahead=20, boot=TRUE)
  plotIRF(var2A.irf.rgdp_growth_adj.nominal_interest_rate)
  var2A.irf.inflation_adj.nominal_interest_rate <- irf(var2A, impulse="inflation_adj", response="nominal_interest_rate", n.ahead=20)
  plotIRF(var2A.irf.inflation_adj.nominal_interest_rate)
}

# VAR 2B: "rgdp_growth_adj", "inflation_adj", "nominal_interest_rate" = Stable, detected serial correlation ----
# Inflation is going up after a shock to interest rate; interest rate is going up after a shock to growth.
if(VAR_2B) {
  var2B.data <- na.omit(real_data_afterReal_quarter[,c("rgdp_growth_adj", "inflation_adj", "nominal_interest_rate")])
  print(VARselect(var2B.data, lag.max = 8)$selection)
  # AIC: 2 lags
  var2B <- VAR(var2B.data, p=2, type="const")
  checkVARStability(var2B)
  # VAR stable!
  checkVARSerialCorr(var2B)
  # Detected correlation!
  
  var2B.irf.nominal_interest_rate.inflation_adj <- irf(var2B, impulse="nominal_interest_rate", response="inflation_adj", n.ahead=20, boot = TRUE)
  plotIRF(var2B.irf.nominal_interest_rate.inflation_adj)
  var2B.irf.nominal_interest_rate.rgdp_growth_adj <- irf(var2B, impulse="nominal_interest_rate", response="rgdp_growth_adj", n.ahead=20, boot = TRUE)
  plotIRF(var2B.irf.nominal_interest_rate.rgdp_growth_adj)
  var2B.irf.rgdp_growth_adj.nominal_interest_rate  <- irf(var2B, impulse="rgdp_growth_adj", response="nominal_interest_rate", n.ahead=20, boot=TRUE)
  plotIRF(var2B.irf.rgdp_growth_adj.nominal_interest_rate)
  var2B.irf.inflation_adj.nominal_interest_rate <- irf(var2B, impulse="inflation_adj", response="nominal_interest_rate", n.ahead=20)
  plotIRF(var2B.irf.inflation_adj.nominal_interest_rate)
}