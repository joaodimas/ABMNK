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
while (!require("hashmap")) install.packages("hashmap")
rm(list = ls())
source("util.R")

VAR_1A = TRUE
VAR_1B = TRUE
VAR_2A = TRUE
VAR_2B = TRUE
VAR_3A = TRUE
VAR_3B = TRUE
VAR_4A = TRUE
VAR_4B = TRUE

real_data_afterReal_month <- read.csv("real_data/real_data_afterReal_month.csv", colClasses = c("date"="Date"))
rownames(real_data_afterReal_month) <- real_data_afterReal_month$date
labelsMap <- hashmap(c("ind_prod", "nominal_interest_rate", "inflation_adj", "logdiff_m1_adj", "real_ex_rate", "logdiff_commodity_index", "ibcbr"),
        c("Industrial Production", "Nominal Interest Rate", "Inflation", "M1 (log diff.)", "Real Exchange Rate", "Commodity Index (log diff.)", "Economic Activity (IBC-br)"))
# VAR 1A: "nominal_interest_rate", "ind_prod", "inflation_adj" =  = stable; NO serial correlation; inflation goes up with interest rate ----
if(VAR_1A) {
  print("ESTIMATING VAR_1A")
  var1A.data <- na.omit(real_data_afterReal_month[,c("nominal_interest_rate", "ind_prod", "inflation_adj")])
  printVARVariables(var1A.data)
  print(VARselect(var1A.data, lag.max = 10)$selection)
  # AIC: 4 lags
  var1A <- VAR(var1A.data, p=4, type="const")
  checkVARStability(var1A)
  # VAR stable!
  checkVARSerialCorr(var1A)
  # Detected serial correlation!
  checkVARHeteroskedasticity(var1A)
  # We detected heteroskedasticity. What should I do?
  checkVARErrorNormality(var1A)
  # Errors are not normally distributed. What should I do?
  
  # Generate orthogonal impulse responses (Cholesky decomposition), shock of 1 unit.
  # Effects of monetary policy:
  var1A.irf.nominal_interest_rate.inflation_adj<- irf(var1A, impulse="nominal_interest_rate", response="inflation_adj", n.ahead=50, boot = TRUE)
  plotIRFToPS(var1A.irf.nominal_interest_rate.inflation_adj)
  
  var1A.irf.nominal_interest_rate.ind_prod <- irf(var1A, impulse="nominal_interest_rate", response="ind_prod", n.ahead=50, boot = TRUE)
  plotIRFToPS(var1A.irf.nominal_interest_rate.ind_prod)
  
  # Monetary policy reaction to other variables:  
  var1A.irf.ind_prod.nominal_interest_rate  <- irf(var1A, impulse="ind_prod", response="nominal_interest_rate", n.ahead=50, boot=TRUE)
  plotIRFToPS(var1A.irf.ind_prod.nominal_interest_rate)
  var1A.irf.inflation_adj.nominal_interest_rate <- irf(var1A, impulse="inflation_adj", response="nominal_interest_rate", n.ahead=50, boot=TRUE)
  plotIRFToPS(var1A.irf.inflation_adj.nominal_interest_rate)
}

# VAR 1B: "ind_prod", "inflation_adj", "nominal_interest_rate" = stable; NO serial correlation ----
if(VAR_1B) {
  print("ESTIMATING VAR_1B")
  var1B.data <- na.omit(real_data_afterReal_month[,c("ind_prod", "inflation_adj", "nominal_interest_rate")])
  var1B.orderSelection <- VARselect(var1B.data, lag.max = 8)
  print(var1B.orderSelection$selection)
  # AIC: 3 lags. However, we keep 4 lags for comparison with VAR 1A
  var1B <- VAR(var1B.data, p=4, type="const")
  checkVARSerialCorr(var1B)
  # With 3 lags we have serial correlation; with 4 problem solved.
  var1B <- VAR(var1B.data, p=4, type="const")
  checkVARSerialCorr(var1B)
  # with 4 lags problem solved.
  checkVARStability(var1B)
  # VAR stable!
  checkVARHeteroskedasticity(var1B)
  # We detected heteroskedasticity. What should I do?
  checkVARErrorNormality(var1B)
  # Errors are not normally distributed. What should I do?
  
  # Generate orthogonal impulse responses (Cholesky decomposition), shock of 1 unit.
  # Effects of monetary policys shocks:
  var1B.irf.nominal_interest_rate.inflation_adj<- irf(var1B, impulse="nominal_interest_rate", response="inflation_adj", n.ahead=40, boot = TRUE)
  plotIRFToPS(var1B.irf.nominal_interest_rate.inflation_adj)
  
  var1B.irf.nominal_interest_rate.ind_prod <- irf(var1B, impulse="nominal_interest_rate", response="ind_prod", n.ahead=50, boot = TRUE)
  plotIRFToPS(var1B.irf.nominal_interest_rate.ind_prod)
  
  # Monetary policy reaction to other variables: 
  var1B.irf.ind_prod.nominal_interest_rate  <- irf(var1B, impulse="ind_prod", response="nominal_interest_rate", n.ahead=50, boot=TRUE)
  plotIRFToPS(var1B.irf.ind_prod.nominal_interest_rate)
  
  var1B.irf.inflation_adj.nominal_interest_rate <- irf(var1B, impulse="inflation_adj", response="nominal_interest_rate", n.ahead=50, boot=TRUE)
  plotIRFToPS(var1B.irf.inflation_adj.nominal_interest_rate)
}


# VAR 2A: "nominal_interest_rate", "logdiff_m1_adj","ind_prod", "inflation_adj" = stable; detected serial correlation----
if(VAR_2A) {
  print("ESTIMATING VAR_2A")
  var2A.data <- na.omit(real_data_afterReal_month[,c("nominal_interest_rate", "logdiff_m1_adj","ind_prod", "inflation_adj")])
  printVARVariables(var2A.data)
  print(VARselect(var2A.data, lag.max = 8)$selection)
  # AIC: 3 lags, but we will continue with 4 lags as in VAR_1A to compare the models.
  var2A <- VAR(var2A.data, p=4, type="const")
  checkVARStability(var2A)
  # VAR stable!
  checkVARSerialCorr(var2A)
  # Detected serial correlation!
  checkVARHeteroskedasticity(var2A)
  # We detected heteroskedasticity. What should I do?
  checkVARErrorNormality(var2A)
  # Errors are not normally distributed. What should I do?
  
  # Generate orthogonal impulse responses (Cholesky decomposition), shock of 1 unit.
  # Effects of monetary policy:
  var2A.irf.nominal_interest_rate.inflation_adj<- irf(var2A, impulse="nominal_interest_rate", response="inflation_adj", n.ahead=50, boot = TRUE)
  plotIRFToPS(var2A.irf.nominal_interest_rate.inflation_adj)
  
  var2A.irf.nominal_interest_rate.logdiff_m1_adj<- irf(var2A, impulse="nominal_interest_rate", response="logdiff_m1_adj", n.ahead=50, boot = TRUE)
  plotIRFToPS(var2A.irf.nominal_interest_rate.logdiff_m1_adj)
  
  var2A.irf.nominal_interest_rate.ind_prod <- irf(var2A, impulse="nominal_interest_rate", response="ind_prod", n.ahead=50, boot = TRUE)
  plotIRFToPS(var2A.irf.nominal_interest_rate.ind_prod)
  
  # Response of interest rate to other variables:
  var2A.irf.ind_prod.nominal_interest_rate  <- irf(var2A, impulse="ind_prod", response="nominal_interest_rate", n.ahead=50, boot=TRUE)
  plotIRFToPS(var2A.irf.ind_prod.nominal_interest_rate)
  
  var2A.irf.inflation_adj.nominal_interest_rate <- irf(var2A, impulse="inflation_adj", response="nominal_interest_rate", n.ahead=50, boot=TRUE)
  plotIRFToPS(var2A.irf.inflation_adj.nominal_interest_rate)
  
  # Cumulative IRF for differenced variables
  var2A.irf.nominal_interest_rate.logdiff_m1_adj.cum <- irf(var2A, impulse="nominal_interest_rate", response="logdiff_m1_adj", n.ahead=50, boot = TRUE, cumulative = TRUE)
  plotIRFToPS(var2A.irf.nominal_interest_rate.logdiff_m1_adj.cum)
  
  var2A.irf.nominal_interest_rate.ind_prod.cum <- irf(var2A, impulse="nominal_interest_rate", response="ind_prod", n.ahead=50, boot = TRUE, cumulative = TRUE)
  plotIRFToPS(var2A.irf.nominal_interest_rate.ind_prod.cum)
}

# VAR 2B: "logdiff_m1_adj","ind_prod", "inflation_adj", "nominal_interest_rate" = stable; detected serial correlation ----
if(VAR_2B) {
  print("ESTIMATING VAR_2B")
  var2B.data <- na.omit(real_data_afterReal_month[,c("logdiff_m1_adj","ind_prod", "inflation_adj", "nominal_interest_rate")])
  print(VARselect(var2B.data, lag.max = 8)$selection)
  # AIC: 3 lags, but we choose 4 lags for comparison with other models
  var2B <- VAR(var2B.data, p=4, type="const")
  checkVARStability(var2B)
  # VAR stable!
  checkVARSerialCorr(var2B)
  # Detected serial correlation!
  checkVARHeteroskedasticity(var2B)
  # We detected heteroskedasticity. What should I do?
  checkVARErrorNormality(var2B)
  # Errors are not normally distributed. What should I do?
  
  # Generate orthogonal impulse responses (Cholesky decomposition), shock of 1 unit.
  # Effects of monetary policy:
  var2B.irf.nominal_interest_rate.logdiff_m1_adj<- irf(var2B, impulse="nominal_interest_rate", response="logdiff_m1_adj", n.ahead=50, boot = TRUE)
  plotIRFToPS(var2B.irf.nominal_interest_rate.logdiff_m1_adj)
  
  var2B.irf.nominal_interest_rate.inflation_adj<- irf(var2B, impulse="nominal_interest_rate", response="inflation_adj", n.ahead=50, boot = TRUE)
  plotIRFToPS(var2B.irf.nominal_interest_rate.inflation_adj)
  
  var2B.irf.nominal_interest_rate.ind_prod <- irf(var2B, impulse="nominal_interest_rate", response="ind_prod", n.ahead=50, boot = TRUE)
  plotIRFToPS(var2B.irf.nominal_interest_rate.ind_prod)
  
  # Response of interest rate to other variables:
  var2B.irf.ind_prod.nominal_interest_rate  <- irf(var2B, impulse="ind_prod", response="nominal_interest_rate", n.ahead=50, boot=TRUE)
  plotIRFToPS(var2B.irf.ind_prod.nominal_interest_rate)
  
  var2B.irf.inflation_adj.nominal_interest_rate <- irf(var2B, impulse="inflation_adj", response="nominal_interest_rate", n.ahead=50, boot=TRUE)
  plotIRFToPS(var2B.irf.inflation_adj.nominal_interest_rate)
  
  # Cumulative IRF for differenced variables
  var2B.irf.nominal_interest_rate.logdiff_m1_adj.cum <- irf(var2B, impulse="nominal_interest_rate", response="logdiff_m1_adj", n.ahead=50, boot = TRUE, cumulative = TRUE)
  plotIRFToPS(var2B.irf.nominal_interest_rate.logdiff_m1_adj.cum)
  
  var2B.irf.nominal_interest_rate.ind_prod.cum <- irf(var2B, impulse="nominal_interest_rate", response="ind_prod", n.ahead=50, boot = TRUE, cumulative = TRUE)
  plotIRFToPS(var2B.irf.nominal_interest_rate.ind_prod.cum)
}

# VAR 3A: "nominal_interest_rate", "real_ex_rate", "logdiff_m1_adj", "ind_prod", "inflation_adj" = stable; detected serial correlation ----
if(VAR_3A) {
  print("ESTIMATING VAR_3A")
  var3A.data <- na.omit(real_data_afterReal_month[,c("nominal_interest_rate", "real_ex_rate", "logdiff_m1_adj","ind_prod", "inflation_adj")])
  printVARVariables(var3A.data)
  print(VARselect(var3A.data, lag.max = 8)$selection)
  # AIC: 4 lags
  var3A <- VAR(var3A.data, p=4, type="const")
  checkVARStability(var3A)
  # VAR stable!
  checkVARSerialCorr(var3A)
  
  # Detected serial correlation!
  checkVARHeteroskedasticity(var3A)
  # We detected heteroskedasticity. What should I do?
  checkVARErrorNormality(var3A)
  # Errors are not normally distributed. What should I do?
  
  # Generate orthogonal impulse responses (Cholesky decomposition), shock of 1 unit.
  
  # Effects of monetary policy:
  var3A.irf.nominal_interest_rate.inflation_adj<- irf(var3A, impulse="nominal_interest_rate", response="inflation_adj", n.ahead=50, boot = TRUE)
  plotIRFToPS(var3A.irf.nominal_interest_rate.inflation_adj)
  
  var3A.irf.nominal_interest_rate.logdiff_m1_adj<- irf(var3A, impulse="nominal_interest_rate", response="logdiff_m1_adj", n.ahead=50, boot = TRUE)
  plotIRFToPS(var3A.irf.nominal_interest_rate.logdiff_m1_adj)
  
  var3A.irf.nominal_interest_rate.ind_prod <- irf(var3A, impulse="nominal_interest_rate", response="ind_prod", n.ahead=50, boot = TRUE)
  plotIRFToPS(var3A.irf.nominal_interest_rate.ind_prod)
  
  var3A.irf.nominal_interest_rate.real_ex_rate<- irf(var3A, impulse="nominal_interest_rate", response="real_ex_rate", n.ahead=50, boot = TRUE)
  plotIRFToPS(var3A.irf.nominal_interest_rate.real_ex_rate)  
  # Curiously, exchange rate starts depreciating after period 8.
  
  # Monetary policy reaction to other variables:
  var3A.irf.ind_prod.nominal_interest_rate  <- irf(var3A, impulse="ind_prod", response="nominal_interest_rate", n.ahead=50, boot=TRUE)
  plotIRFToPS(var3A.irf.ind_prod.nominal_interest_rate)
  
  var3A.irf.inflation_adj.nominal_interest_rate <- irf(var3A, impulse="inflation_adj", response="nominal_interest_rate", n.ahead=50, boot=TRUE)
  plotIRFToPS(var3A.irf.inflation_adj.nominal_interest_rate)
  
  var3A.irf.real_ex_rate.nominal_interest_rate <- irf(var3A, impulse="real_ex_rate", response="nominal_interest_rate", n.ahead=50, boot=TRUE)
  plotIRFToPS(var3A.irf.real_ex_rate.nominal_interest_rate)
  
  # Cumulative IRF for differenced variables
  var3A.irf.nominal_interest_rate.logdiff_m1_adj.cum <- irf(var3A, impulse="nominal_interest_rate", response="logdiff_m1_adj", n.ahead=50, boot = TRUE, cumulative = TRUE)
  plotIRFToPS(var3A.irf.nominal_interest_rate.logdiff_m1_adj.cum)
  
  var3A.irf.nominal_interest_rate.ind_prod.cum <- irf(var3A, impulse="nominal_interest_rate", response="ind_prod", n.ahead=50, boot = TRUE, cumulative = TRUE)
  plotIRFToPS(var3A.irf.nominal_interest_rate.ind_prod.cum)
}

# VAR 3B: "real_ex_rate", "logdiff_m1_adj","ind_prod", "inflation_adj", "nominal_interest_rate" = stable; detected serial correlation ----
if(VAR_3B) {
  print("ESTIMATING VAR_3B")
  var3B.data <- na.omit(real_data_afterReal_month[,c("real_ex_rate", "logdiff_m1_adj","ind_prod", "inflation_adj", "nominal_interest_rate")])
  print(VARselect(var3B.data, lag.max = 8)$selection)
  # AIC: 4 lags
  var3B <- VAR(var3B.data, p=4, type="const")
  checkVARStability(var3B)
  # VAR stable!
  checkVARSerialCorr(var3B)
  
  # Detected serial correlation!
  checkVARHeteroskedasticity(var3B)
  # We detected heteroskedasticity. What should I do?
  checkVARErrorNormality(var3B)
  # Errors are not normally distributed. What should I do?
  
  # Generate orthogonal impulse responses (Cholesky decomposition), shock of 1 unit.
  
  # Effects of monetary policy:
  var3B.irf.nominal_interest_rate.inflation_adj<- irf(var3B, impulse="nominal_interest_rate", response="inflation_adj", n.ahead=50, boot = TRUE)
  plotIRFToPS(var3B.irf.nominal_interest_rate.inflation_adj)
  
  var3B.irf.nominal_interest_rate.logdiff_m1_adj<- irf(var3B, impulse="nominal_interest_rate", response="logdiff_m1_adj", n.ahead=50, boot = TRUE)
  plotIRFToPS(var3B.irf.nominal_interest_rate.logdiff_m1_adj)
  
  var3B.irf.nominal_interest_rate.ind_prod <- irf(var3B, impulse="nominal_interest_rate", response="ind_prod", n.ahead=50, boot = TRUE)
  plotIRFToPS(var3B.irf.nominal_interest_rate.ind_prod)
  
  var3B.irf.nominal_interest_rate.real_ex_rate<- irf(var3B, impulse="nominal_interest_rate", response="real_ex_rate", n.ahead=50, boot = TRUE)
  plotIRFToPS(var3B.irf.nominal_interest_rate.real_ex_rate)  
  # Curiously, exchange rate starts depreciating after period 8.
  
  # Monetary policy reaction to other variables:
  var3B.irf.ind_prod.nominal_interest_rate  <- irf(var3B, impulse="ind_prod", response="nominal_interest_rate", n.ahead=50, boot=TRUE)
  plotIRFToPS(var3B.irf.ind_prod.nominal_interest_rate)
  
  var3B.irf.inflation_adj.nominal_interest_rate <- irf(var3B, impulse="inflation_adj", response="nominal_interest_rate", n.ahead=50, boot=TRUE)
  plotIRFToPS(var3B.irf.inflation_adj.nominal_interest_rate)
  
  var3B.irf.real_ex_rate.nominal_interest_rate <- irf(var3B, impulse="real_ex_rate", response="nominal_interest_rate", n.ahead=50, boot=TRUE)
  plotIRFToPS(var3B.irf.real_ex_rate.nominal_interest_rate)
  
  # Cumulative IRF for differenced variables
  var3B.irf.nominal_interest_rate.logdiff_m1_adj.cum <- irf(var3B, impulse="nominal_interest_rate", response="logdiff_m1_adj", n.ahead=50, boot = TRUE, cumulative = TRUE)
  plotIRFToPS(var3B.irf.nominal_interest_rate.logdiff_m1_adj.cum)
  
  var3B.irf.nominal_interest_rate.ind_prod.cum <- irf(var3B, impulse="nominal_interest_rate", response="ind_prod", n.ahead=50, boot = TRUE, cumulative = TRUE)
  plotIRFToPS(var3B.irf.nominal_interest_rate.ind_prod.cum)
}

# VAR 4A: "nominal_interest_rate", "real_ex_rate", "logdiff_commodity_index", "logdiff_m1_adj", "ind_prod", "inflation_adj" = stable; detected serial correlation ----
if(VAR_4A) {
  print("ESTIMATING VAR_4A")
  var4A.data <- na.omit(real_data_afterReal_month[,c("nominal_interest_rate", "real_ex_rate", "logdiff_commodity_index", "logdiff_m1_adj", "ind_prod", "inflation_adj")])
  printVARVariables(var4A.data)
  print(VARselect(var4A.data, lag.max = 8)$selection)
  # AIC: 4 lags
  var4A <- VAR(var4A.data, p=4, type="const")
  checkVARStability(var4A)
  # VAR stable!
  checkVARSerialCorr(var4A)
  
  # Detected serial correlation!
  checkVARHeteroskedasticity(var4A)
  # We detected heteroskedasticity. What should I do?
  checkVARErrorNormality(var4A)
  # Errors are not normally distributed. What should I do?
  
  # Generate orthogonal impulse responses (Cholesky decomposition), shock of 1 unit.
  
  # Effects of monetary policy:
  var4A.irf.nominal_interest_rate.inflation_adj<- irf(var4A, impulse="nominal_interest_rate", response="inflation_adj", n.ahead=50, boot = TRUE)
  plotIRFToPS(var4A.irf.nominal_interest_rate.inflation_adj)
  
  var4A.irf.nominal_interest_rate.logdiff_m1_adj<- irf(var4A, impulse="nominal_interest_rate", response="logdiff_m1_adj", n.ahead=50, boot = TRUE)
  plotIRFToPS(var4A.irf.nominal_interest_rate.logdiff_m1_adj)
  
  var4A.irf.nominal_interest_rate.ind_prod <- irf(var4A, impulse="nominal_interest_rate", response="ind_prod", n.ahead=50, boot = TRUE)
  plotIRFToPS(var4A.irf.nominal_interest_rate.ind_prod)
  
  var4A.irf.nominal_interest_rate.real_ex_rate<- irf(var4A, impulse="nominal_interest_rate", response="real_ex_rate", n.ahead=50, boot = TRUE)
  plotIRFToPS(var4A.irf.nominal_interest_rate.real_ex_rate)  
  # Curiously, exchange rate starts depreciating after period 8.
  
  # Monetary policy reaction to other variables:
  var4A.irf.ind_prod.nominal_interest_rate  <- irf(var4A, impulse="ind_prod", response="nominal_interest_rate", n.ahead=50, boot=TRUE)
  plotIRFToPS(var4A.irf.ind_prod.nominal_interest_rate)
  
  var4A.irf.inflation_adj.nominal_interest_rate <- irf(var4A, impulse="inflation_adj", response="nominal_interest_rate", n.ahead=50, boot=TRUE)
  plotIRFToPS(var4A.irf.inflation_adj.nominal_interest_rate)
  
  var4A.irf.real_ex_rate.nominal_interest_rate <- irf(var4A, impulse="real_ex_rate", response="nominal_interest_rate", n.ahead=50, boot=TRUE)
  plotIRFToPS(var4A.irf.real_ex_rate.nominal_interest_rate)
  
  var4A.irf.logdiff_commodity_index.nominal_interest_rate <- irf(var4A, impulse="logdiff_commodity_index", response="nominal_interest_rate", n.ahead=50, boot=TRUE)
  plotIRFToPS(var4A.irf.logdiff_commodity_index.nominal_interest_rate)
  
  # How commodity prices affect real exchange rate:
  var4A.irf.logdiff_commodity_index.real_ex_rate <- irf(var4A, impulse="logdiff_commodity_index", response="real_ex_rate", n.ahead=50, boot=TRUE)
  plotIRFToPS(var4A.irf.logdiff_commodity_index.real_ex_rate)
  
  # Cumulative IRF for differenced variables
  var4A.irf.nominal_interest_rate.logdiff_m1_adj.cum <- irf(var4A, impulse="nominal_interest_rate", response="logdiff_m1_adj", n.ahead=50, boot = TRUE, cumulative = TRUE)
  plotIRFToPS(var4A.irf.nominal_interest_rate.logdiff_m1_adj.cum)
  
  var4A.irf.nominal_interest_rate.ind_prod.cum <- irf(var4A, impulse="nominal_interest_rate", response="ind_prod", n.ahead=50, boot = TRUE, cumulative = TRUE)
  plotIRFToPS(var4A.irf.nominal_interest_rate.ind_prod.cum)
}

# VAR 4B: "real_ex_rate", "logdiff_commodity_index", "logdiff_m1_adj", "ind_prod", "inflation_adj", "nominal_interest_rate" = stable; detected serial correlation ----
if(VAR_4B) {
  print("ESTIMATING VAR_4B")
  var4B.data <- na.omit(real_data_afterReal_month[,c("real_ex_rate", "logdiff_commodity_index", "logdiff_m1_adj", "ind_prod", "inflation_adj", "nominal_interest_rate")])
  print(VARselect(var4B.data, lag.max = 8)$selection)
  # AIC: 4 lags
  var4B <- VAR(var4B.data, p=4, type="const")
  checkVARStability(var4B)
  # VAR stable!
  checkVARSerialCorr(var4B)
  
  # Detected serial correlation!
  checkVARHeteroskedasticity(var4B)
  # We detected heteroskedasticity. What should I do?
  checkVARErrorNormality(var4B)
  # Errors are not normally distributed. What should I do?
  
  # Generate orthogonal impulse responses (Cholesky decomposition), shock of 1 unit.
  
  # Effects of monetary policy:
  var4B.irf.nominal_interest_rate.inflation_adj<- irf(var4B, impulse="nominal_interest_rate", response="inflation_adj", n.ahead=50, boot = TRUE)
  plotIRFToPS(var4B.irf.nominal_interest_rate.inflation_adj)
  
  var4B.irf.nominal_interest_rate.logdiff_m1_adj<- irf(var4B, impulse="nominal_interest_rate", response="logdiff_m1_adj", n.ahead=50, boot = TRUE)
  plotIRFToPS(var4B.irf.nominal_interest_rate.logdiff_m1_adj)
  
  var4B.irf.nominal_interest_rate.ind_prod <- irf(var4B, impulse="nominal_interest_rate", response="ind_prod", n.ahead=50, boot = TRUE)
  plotIRFToPS(var4B.irf.nominal_interest_rate.ind_prod)
  
  var4B.irf.nominal_interest_rate.real_ex_rate<- irf(var4B, impulse="nominal_interest_rate", response="real_ex_rate", n.ahead=50, boot = TRUE)
  plotIRFToPS(var4B.irf.nominal_interest_rate.real_ex_rate)  
  # Curiously, exchange rate starts depreciating after period 8.
  
  # Monetary policy reaction to other variables:
  var4B.irf.ind_prod.nominal_interest_rate  <- irf(var4B, impulse="ind_prod", response="nominal_interest_rate", n.ahead=50, boot=TRUE)
  plotIRFToPS(var4B.irf.ind_prod.nominal_interest_rate)
  
  var4B.irf.inflation_adj.nominal_interest_rate <- irf(var4B, impulse="inflation_adj", response="nominal_interest_rate", n.ahead=50, boot=TRUE)
  plotIRFToPS(var4B.irf.inflation_adj.nominal_interest_rate)
  
  var4B.irf.real_ex_rate.nominal_interest_rate <- irf(var4B, impulse="real_ex_rate", response="nominal_interest_rate", n.ahead=50, boot=TRUE)
  plotIRFToPS(var4B.irf.real_ex_rate.nominal_interest_rate)
  
  var4B.irf.logdiff_commodity_index.nominal_interest_rate <- irf(var4B, impulse="logdiff_commodity_index", response="nominal_interest_rate", n.ahead=50, boot=TRUE)
  plotIRFToPS(var4B.irf.logdiff_commodity_index.nominal_interest_rate)
  
  # How commodity prices affect real exchange rate:
  var4B.irf.logdiff_commodity_index.real_ex_rate <- irf(var4B, impulse="logdiff_commodity_index", response="real_ex_rate", n.ahead=50, boot=TRUE)
  plotIRFToPS(var4B.irf.logdiff_commodity_index.real_ex_rate)
  
  # Cumulative IRF for differenced variables
  var4B.irf.nominal_interest_rate.logdiff_m1_adj.cum <- irf(var4B, impulse="nominal_interest_rate", response="logdiff_m1_adj", n.ahead=50, boot = TRUE, cumulative = TRUE)
  plotIRFToPS(var4B.irf.nominal_interest_rate.logdiff_m1_adj.cum)
  
  var4B.irf.nominal_interest_rate.ind_prod.cum <- irf(var4B, impulse="nominal_interest_rate", response="ind_prod", n.ahead=50, boot = TRUE, cumulative = TRUE)
  plotIRFToPS(var4B.irf.nominal_interest_rate.ind_prod.cum)
}



