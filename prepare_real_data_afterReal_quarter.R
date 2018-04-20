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
rm(list = ls())
source("util.R")

# Import data ----
real_data_quarter <- read.csv("real_data/data_quarter.csv", colClasses = c("date"="Date"))
# Select time period after Real ----
real_data_afterReal <- real_data_quarter[which(real_data_quarter$date >= "1995-01-01" & real_data_quarter$date <= "2017-12-31"),]
# (1) Check stationarity of level variables ----
#   (1.1) Commodity index ---- Not stationary
plotline(real_data_afterReal$commodity_index)
checkStationarity(real_data_afterReal$commodity_index)

real_data_afterReal$log_commodity_index <- log(real_data_afterReal$commodity_index)
plotline(real_data_afterReal$log_commodity_index)
checkStationarity(real_data_afterReal$log_commodity_index)

real_data_afterReal$logdiff_commodity_index <- c(NA,diff(real_data_afterReal$log_commodity_index))
plotline(real_data_afterReal$logdiff_commodity_index)
checkStationarity(real_data_afterReal$logdiff_commodity_index)

real_data_afterReal$log_commodity_index <- NULL

# (2) Check seasonality and adjust series if needed ----
#   (2.1) Inflation: strong seasonality. ----
ts_inflation <- ts(real_data_afterReal$inflation, start=year(real_data_afterReal$date[1]), deltat = 1/4)
x13_inflation <- seas(ts_inflation, transform.function = "none", regression.aictest = NULL)
summary(x13_inflation)
real_data_afterReal$inflation_adj <- final(x13_inflation)

plot_ly(real_data_afterReal, x=~date, y=~inflation, mode="lines", type="scatter", name="Actual inflation") %>%
  add_trace(y=~inflation_adj, name="Adjusted inflation")

#   (2.2) GDP growth (previous quarter): strong seasonality. ----
ts_gdpgrowth <- ts(real_data_afterReal$rgdp_growth, start=year(real_data_afterReal$date[1]), deltat = 1/4)
x13_gdpgrowth <- seas(ts_gdpgrowth, transform.function = "none", regression.aictest = NULL)
summary(x13_gdpgrowth)
real_data_afterReal$rgdp_growth_adj <- c(NA, final(x13_gdpgrowth), NA)

plot_ly(real_data_afterReal, x=~date, y=~rgdp_growth, mode="lines", type="scatter", name="Actual GDP growth") %>%
  add_trace(y=~rgdp_growth_adj, name="Adjusted GDP growth")

#   (2.3) Output gap: small seasonality: probably the series is already seasonally adjusted. ----
ts_output_gap <- ts(real_data_afterReal$output_gap, start=year(real_data_afterReal$date[1]), deltat = 1/4)
x13_output_gap <- seas(ts_output_gap, transform.function = "none", regression.aictest = NULL)
summary(x13_output_gap)
real_data_afterReal$output_gap_adj <- final(x13_output_gap)

plot_ly(real_data_afterReal, x=~date, y=~output_gap, mode="lines", type="scatter", name="Actual output_gap") %>%
  add_trace(y=~output_gap_adj, name="Adjusted output_gap")

real_data_afterReal$output_gap_adj <- NULL # delete the unnecessary adjusted series.

#   (2.4) Nominal interest rate: no seasonality. ----
ts_nominal_interest_rate <- ts(real_data_afterReal$nominal_interest_rate, start=year(real_data_afterReal$date[1]), deltat = 1/4)
x13_nominal_interest_rate <- seas(ts_nominal_interest_rate, transform.function = "none", regression.aictest = NULL)
summary(x13_nominal_interest_rate)
real_data_afterReal$nominal_interest_rate_adj <- final(x13_nominal_interest_rate)

plot_ly(real_data_afterReal, x=~date, y=~nominal_interest_rate, mode="lines", type="scatter", name="Actual nominal_interest_rate") %>%
  add_trace(y=~nominal_interest_rate_adj, name="Adjusted nominal_interest_rate")

real_data_afterReal$nominal_interest_rate_adj <- NULL # delete the unnecessary adjusted series.

#   (2.5) Real exchange rate: no seasonality. ----
ts_real_ex_rate <- ts(real_data_afterReal$real_ex_rate, start=year(real_data_afterReal$date[1]), deltat = 1/4)
x13_real_ex_rate <- seas(ts_real_ex_rate, transform.function = "none", regression.aictest = NULL)
summary(x13_real_ex_rate)
real_data_afterReal$real_ex_rate_adj <- final(x13_real_ex_rate)

plot_ly(real_data_afterReal, x=~date, y=~real_ex_rate, mode="lines", type="scatter", name="Actual real_ex_rate") %>%
  add_trace(y=~real_ex_rate_adj, name="Adjusted real_ex_rate")

real_data_afterReal$real_ex_rate_adj <- NULL # delete the unnecessary adjusted series.
#   (2.6) Commodities prices (log diff): no seasonality. ----
ts_logdiff_commodity_index <- ts(real_data_afterReal$logdiff_commodity_index, start=year(real_data_afterReal$date[1]), deltat = 1/4)
x13_logdiff_commodity_index <- seas(ts_logdiff_commodity_index, transform.function = "none", regression.aictest = NULL)
summary(x13_logdiff_commodity_index)
real_data_afterReal$logdiff_commodity_index_adj <- c(rep(NA, nrow(real_data_afterReal) - length(final(x13_logdiff_commodity_index))),final(x13_logdiff_commodity_index))

plot_ly(real_data_afterReal, x=~date, y=~logdiff_commodity_index, mode="lines", type="scatter", name="Actual logdiff_commodity_index") %>%
  add_trace(y=~logdiff_commodity_index_adj, name="Adjusted logdiff_commodity_index")

real_data_afterReal$logdiff_commodity_index_adj <- NULL # delete the unnecessary adjusted series.

# Write CSV ---- 
write.csv(real_data_afterReal, "real_data/real_data_afterReal_quarter.csv", row.names = FALSE)