# (0) Prepare the environment, import data and select time period after Real ----
while (!require("plotly")) install.packages("plotly")
while (!require("tseries")) install.packages("tseries")
while (!require("vars")) install.packages("vars")
while (!require("strucchange")) install.packages("strucchange")
while (!require("ecm")) install.packages("ecm")
while (!require("x12")) install.packages("x12")
while (!require("seasonal")) install.packages("seasonal")
while (!require("lubridate")) install.packages("lubridate")
while (!require("forecast")) install.packages("forecast")
rm(list = ls())
source("util.R")

# Import data
real_data_month <- read.csv("real_data/data_month.csv", colClasses = c("date"="Date"))
# Select time period after Real
real_data_afterReal_month <- real_data_month[which(real_data_month$date >= "1995-01-01" & real_data_month$date <= "2017-12-31"),]
# (1) Check stationarity of level variables ----
#   (1.1) Commodity index ---- Not stationary
plotline(real_data_afterReal_month$commodity_index)
# Clearly not stationary
checkStationarity(real_data_afterReal_month$commodity_index)
# Not stationary for 5% confidence interval.

real_data_afterReal_month$log_commodity_index <- log(real_data_afterReal_month$commodity_index)
plotline(real_data_afterReal_month$log_commodity_index)
checkStationarity(real_data_afterReal_month$log_commodity_index)
# Not stationary for 5% confidence interval.

real_data_afterReal_month$logdiff_commodity_index <- c(NA,diff(real_data_afterReal_month$log_commodity_index))
plotline(real_data_afterReal_month$logdiff_commodity_index)
checkStationarity(real_data_afterReal_month$logdiff_commodity_index)
# Yes. Stationary for 1% confidence interval.

real_data_afterReal_month$log_commodity_index <- NULL



#   (1.1) Commodity prices ----
plotline(real_data_afterReal_month$commodity_index)
# Clearly not stationary
checkStationarity(real_data_afterReal_month$commodity_index)
# Not stationary for 5% confidence interval.

real_data_afterReal_month$log_commodity_index <- log(real_data_afterReal_month$commodity_index)
plotline(real_data_afterReal_month$log_commodity_index)
checkStationarity(real_data_afterReal_month$log_commodity_index)
# Not stationary for 5% confidence interval.

real_data_afterReal_month$logdiff_commodity_index <- c(NA,diff(real_data_afterReal_month$log_commodity_index))
plotline(real_data_afterReal_month$logdiff_commodity_index)
checkStationarity(real_data_afterReal_month$logdiff_commodity_index)
# Yes. Stationary for 1% confidence interval.

real_data_afterReal_month$log_commodity_index <- NULL

#   (1.2) M1 ----
plotline(real_data_afterReal_month$m1)
# Clearly not stationary
checkStationarity(real_data_afterReal_month$m1)
# Not stationary for 10% confidence interval.

real_data_afterReal_month$log_m1 <- log(real_data_afterReal_month$m1)
plotline(real_data_afterReal_month$log_m1)
checkStationarity(real_data_afterReal_month$log_m1)
# Not stationary for 10% confidence interval.

real_data_afterReal_month$logdiff_m1 <- c(NA,diff(real_data_afterReal_month$log_m1))
plotline(real_data_afterReal_month$logdiff_m1)
checkStationarity(real_data_afterReal_month$logdiff_m1)
# Yes. Stationary for 1% confidence interval.

real_data_afterReal_month$log_m1 <- NULL

#   (1.3) IBC-br ----
plotline(real_data_afterReal_month$ibcbr)
# Clearly not stationary
checkStationarity(real_data_afterReal_month$ibcbr)
# Not stationary for 10% confidence interval.

real_data_afterReal_month$log_ibcbr <- log(real_data_afterReal_month$ibcbr)
plotline(real_data_afterReal_month$log_ibcbr)
checkStationarity(real_data_afterReal_month$log_ibcbr)
# Not stationary for 10% confidence interval.

real_data_afterReal_month$logdiff_ibcbr <- c(NA,diff(real_data_afterReal_month$log_ibcbr))
plotline(real_data_afterReal_month$logdiff_ibcbr)
checkStationarity(real_data_afterReal_month$logdiff_ibcbr)
# Yes. Stationary for 1% confidence interval.

real_data_afterReal_month$log_ibcbr <- NULL

# (2) Check seasonality and adjust series if needed ----
#   (2.1) Inflation: strong seasonality. ----
ts_inflation <- ts(real_data_afterReal_month$inflation, start=year(real_data_afterReal_month$date[1]), deltat = 1/12)
x13_inflation <- seas(ts_inflation, transform.function = "none", regression.aictest = NULL)
summary(x13_inflation)
real_data_afterReal_month$inflation_adj <- final(x13_inflation)

plot_ly(real_data_afterReal_month, x=~date, y=~inflation, mode="lines", type="scatter", name="Actual inflation") %>%
  add_trace(y=~inflation_adj, name="Adjusted inflation")

#   (2.2) GDP growth NOT AVAILABLE in monthly data. ----

#   (2.3) Output gap NOT AVAILABLE in monthly data. ----

#   (2.4) Nominal interest rate: no seasonality. ----
ts_nominal_interest_rate <- ts(real_data_afterReal_month$nominal_interest_rate, start=year(real_data_afterReal_month$date[1]), deltat = 1/12)
x13_nominal_interest_rate <- seas(ts_nominal_interest_rate, transform.function = "none", regression.aictest = NULL)
summary(x13_nominal_interest_rate)
real_data_afterReal_month$nominal_interest_rate_adj <- final(x13_nominal_interest_rate)

plot_ly(real_data_afterReal_month, x=~date, y=~nominal_interest_rate, mode="lines", type="scatter", name="Actual nominal_interest_rate") %>%
  add_trace(y=~nominal_interest_rate_adj, name="Adjusted nominal_interest_rate")

real_data_afterReal_month$nominal_interest_rate_adj <- NULL # delete the unnecessary adjusted series.

#   (2.5) Real exchange rate: no seasonality. ----
ts_real_ex_rate <- ts(real_data_afterReal_month$real_ex_rate, start=year(real_data_afterReal_month$date[1]), deltat = 1/12)
x13_real_ex_rate <- seas(ts_real_ex_rate, transform.function = "none", regression.aictest = NULL)
summary(x13_real_ex_rate)
real_data_afterReal_month$real_ex_rate_adj <- final(x13_real_ex_rate)

plot_ly(real_data_afterReal_month, x=~date, y=~real_ex_rate, mode="lines", type="scatter", name="Actual real_ex_rate") %>%
  add_trace(y=~real_ex_rate_adj, name="Adjusted real_ex_rate")

real_data_afterReal_month$real_ex_rate_adj <- NULL # delete the unnecessary adjusted series.
#   (2.6) Commodities prices (log diff): no seasonality. ----
ts_logdiff_commodity_index <- ts(real_data_afterReal_month$logdiff_commodity_index, start=year(real_data_afterReal_month$date[1]), deltat = 1/12)
x13_logdiff_commodity_index <- seas(ts_logdiff_commodity_index, transform.function = "none", regression.aictest = NULL)
summary(x13_logdiff_commodity_index)
real_data_afterReal_month$logdiff_commodity_index_adj <- c(rep(NA, nrow(real_data_afterReal_month) - length(final(x13_logdiff_commodity_index))),final(x13_logdiff_commodity_index))

plot_ly(real_data_afterReal_month, x=~date, y=~logdiff_commodity_index, mode="lines", type="scatter", name="Actual logdiff_commodity_index") %>%
  add_trace(y=~logdiff_commodity_index_adj, name="Adjusted logdiff_commodity_index")

real_data_afterReal_month$logdiff_commodity_index_adj <- NULL # delete the unnecessary adjusted series.
#   (2.7) M1 (log diff): strong seasonality. ----
ts_logdiff_m1 <- ts(real_data_afterReal_month$logdiff_m1, start=year(real_data_afterReal_month$date[1]), deltat = 1/12)
x13_logdiff_m1 <- seas(ts_logdiff_m1, transform.function = "none", regression.aictest = NULL)
summary(x13_logdiff_m1)
real_data_afterReal_month$logdiff_m1_adj <- c(NA,final(x13_logdiff_m1))

plot_ly(real_data_afterReal_month, x=~date, y=~logdiff_m1, mode="lines", type="scatter", name="Actual logdiff_m1") %>%
  add_trace(y=~logdiff_m1_adj, name="Adjusted logdiff_m1")
#   (2.8) IBC-br (log diff): already seasonally adjusted from the BCB database  ----
ts_logdiff_ibcbr <- ts(real_data_afterReal_month$logdiff_ibcbr, start=year(real_data_afterReal_month$date[1]), deltat = 1/12)
x13_logdiff_ibcbr <- seas(ts_logdiff_ibcbr, transform.function = "none", regression.aictest = NULL)
summary(x13_logdiff_ibcbr)
real_data_afterReal_month$logdiff_ibcbr_adj <- c(rep(NA, nrow(real_data_afterReal_month) - length(final(x13_logdiff_ibcbr))),final(x13_logdiff_ibcbr))

plot_ly(real_data_afterReal_month, x=~date, y=~logdiff_ibcbr, mode="lines", type="scatter", name="Actual logdiff_ibcbr") %>%
  add_trace(y=~logdiff_ibcbr_adj, name="Adjusted logdiff_ibcbr")

real_data_afterReal_month$logdiff_ibcbr_adj <- NULL  # delete the unnecessary adjusted series.
# Write CSV ---- 
write.csv(real_data_afterReal_month, "real_data/real_data_afterReal_month.csv", row.names = FALSE)
