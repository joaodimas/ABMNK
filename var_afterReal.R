# Prepare the environment ----
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

VAR_1 = TRUE
VAR_2 = TRUE

# Import data ----
real_data_afterReal <- read.csv("real_data/real_data_afterReal.csv", row.names="date", colClasses = c("date"="Date"))

# VAR 1: "nominal_interest_rate", "output_gap", "inflation_adj" = Stable, no serial correlation, initial hump in inflation's dynamic response ----
if(VAR_1) {
  var1.data <- na.omit(real_data_afterReal[,c("nominal_interest_rate", "output_gap", "inflation_adj")])
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
  plot(var1.irf.output_gap.nominal_interest_rate)
  var1.irf.inflation_adj.nominal_interest_rate <- irf(var1, impulse="inflation_adj", response="nominal_interest_rate", n.ahead=20, boot=TRUE)
  plot(var1.irf.inflation_adj.nominal_interest_rate)
}

# VAR 2: "output_gap", "inflation_adj", "nominal_interest_rate" = Stable, no serial correlation ----
if(VAR_2) {
  var2.data <- na.omit(real_data_afterReal[,c("output_gap", "inflation_adj", "nominal_interest_rate")])
  print(VARselect(var2.data, lag.max = 8)$selection)
  # AIC: 2 lags
  var2 <- VAR(var2.data, p=2, type="const")
  checkVARStability(var2)
  # VAR stable!
  checkVARSerialCorr(var2)
  # No serial correlation!
  checkVARHeteroskedasticity(var2)
  # We detected heteroskedasticity. What should I do?
  checkVARErrorNormality(var2)
  # Errors are not normally distributed. What should I do?
  
  # Generate orthogonal impulse responses (Cholesky decomposition), shock of 1 unit.
  var2.irf.nominal_interest_rate.inflation_adj<- irf(var2, impulse="nominal_interest_rate", response="inflation_adj", n.ahead=20, boot = TRUE)
  plotIRF(var2.irf.nominal_interest_rate.inflation_adj, impulseName = "Interest Rate", responseName = "Inflation", yAxisDTick = 0.002)
  var2.irf.nominal_interest_rate.output_gap <- irf(var2, impulse="nominal_interest_rate", response="output_gap", n.ahead=20, boot = TRUE)
  plotIRF(var2.irf.nominal_interest_rate.output_gap)
  var2.irf.output_gap.nominal_interest_rate  <- irf(var2, impulse="output_gap", response="nominal_interest_rate", n.ahead=20, boot=TRUE)
  plotIRF(var2.irf.output_gap.nominal_interest_rate, yAxisDTick = 0.005)
  var2.irf.inflation_adj.nominal_interest_rate <- irf(var2, impulse="inflation_adj", response="nominal_interest_rate", n.ahead=20, boot=TRUE)
  plotIRF(var2.irf.inflation_adj.nominal_interest_rate, yAxisDTick = 0.005)
}


# VAR 2: "inflation_adj", "rgdp_growth_adj", "nominal_interest_rate" = Stable, no serial correlation ----
if(VAR_2) {
  var2.data <- na.omit(real_data_afterReal[,c("inflation_adj", "rgdp_growth_adj", "nominal_interest_rate")])
  print(VARselect(var2.data, lag.max = 8)$selection)
  # AIC: 2 lags
  var2 <- VAR(var2.data, p=2, type="const")
  checkVARStability(var2)
  # VAR stable!
  checkVARSerialCorr(var2)
  # Detected correlation!
  
  var2.irf.nominal_interest_rate.inflation_adj <- irf(var2, impulse="nominal_interest_rate", response="inflation_adj", n.ahead=20, boot = TRUE)
  plot(var2.irf.nominal_interest_rate.inflation_adj)
  var2.irf.nominal_interest_rate.rgdp_growth_adj <- irf(var2, impulse="nominal_interest_rate", response="rgdp_growth_adj", n.ahead=20, boot = TRUE)
  plot(var2.irf.nominal_interest_rate.rgdp_growth_adj)
  var2.irf.rgdp_growth_adj.nominal_interest_rate  <- irf(var2, impulse="rgdp_growth_adj", response="nominal_interest_rate", n.ahead=20, boot=TRUE)
  plot(var2.irf.rgdp_growth_adj.nominal_interest_rate)
  var2.irf.inflation_adj.nominal_interest_rate <- irf(var2, impulse="inflation_adj", response="nominal_interest_rate", n.ahead=20)
  plot(var2.irf.inflation_adj.nominal_interest_rate)
}
# VAR 3: add commodity prices

# VAR 4: add real exchange rate