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

# Enable parts of the code ----
ENABLE_1 <- FALSE
ENABLE_2 <- FALSE
ENABLE_3 <- FALSE
ENABLE_4 <- FALSE

# Initial import ----
setwd("/Users/jdimas/GitHub/ABMNK/real_data")
real_data <- read.csv("data.csv", colClasses=c("Date", rep("numeric", 21)))
real_data2 <- tail(na.omit(real_data[,c("date", "inflation", "exp_inflation", "nominal_interest_rate", "output_gap")]),88)
real_data2$inflation_diff <- c(NA, diff(real_data2$inflation))
real_data2$exp_inflation_diff <- c(NA, diff(real_data2$exp_inflation))
real_data2$nominal_interest_rate_diff <- c(NA, diff(real_data2$nominal_interest_rate))
real_data2$output_gap_diff <- c(NA, diff(real_data2$output_gap))
real_data2 <- na.omit(real_data2)
write.csv(real_data2, file ="data2.csv", row.names=FALSE)
real_data_afterReal <- real_data[which(real_data$date >= "1995-01-01" & real_data$date <= "2017-12-31"),]

# (1) Monetary policy responding to expected inflation ----
if(ENABLE_1) {
  df <- na.omit(real_data[,c("date", "exp_inflation", "nominal_interest_rate", "real_interest_rate")])
  rownames(df) <- c(1:nrow(df))
  plot_ly(df, x=~date, y = ~exp_inflation, name = 'expected inflation', type="scatter", mode = 'lines+markers',  hoverinfo = 'text', text = ~paste(rownames(df), date, exp_inflation, sep="<br>")) %>%
    add_trace(y = ~real_interest_rate, name = 'real interest rate') %>%
    add_trace(y = ~nominal_interest_rate, name = 'nominal interest rate') 
  
  # There's a clear change in how monetary policy responds to inflation starting in October 2011. 
  # We see that expected inflation is still high, but the Central Bank starts decreasing interest rates.
  # The 'strange' behavior lasts until April 2013, when the Central Bank starts a smooth tightening of monetary policy.
  # We also see a maintenance of a high nominal rate from Jan to July 2016 even after expected inflation started decreasing.
  # This caused an increase in real rates as inflation went down. Shouldn't the CB have reacted quickly?
  
  # Exploratory: compare the R2 of different lags on interest_rate, both real and nominal.
  lm1 <- summary(lm(nominal_interest_rate ~ lagpad(exp_inflation,1), df))
  lm2 <- summary(lm(nominal_interest_rate ~ exp_inflation, df))
  lm3 <- summary(lm(real_interest_rate ~ lagpad(exp_inflation,1), df))
  lm_inflation <- summary(lm(real_interest_rate ~ exp_inflation, df))
  print(paste("lm1 R2: ",lm1$r.squared))
  print(paste("lm2 R2: ",lm2$r.squared))
  print(paste("lm3 R2: ",lm3$r.squared))
  print(paste("lm_inflation R2: ",lm_inflation$r.squared))
  # Highest R2 is nominal_interest_rate ~ exp_inflation lagged.
  
  breakpoints(nominal_interest_rate ~ lagpad(exp_inflation,1), data=df)$breakpoints
  # Breakpoints at observation number: 18 28 41 54 
  breakpoints(real_interest_rate ~ lagpad(exp_inflation,1), data=df)$breakpoints
  # Breakpoints at observation number: 19 28 41 54 
}
# (2) Monetary policy x Output gap and expected inflation ----
if(ENABLE_2) {
  df <- na.omit(real_data2[,c("date", "nominal_interest_rate", "real_interest_rate", "output_gap", "exp_inflation", "inflation")])
  rownames(df) <- c(1:nrow(df))
  plot_ly(df, x=~date, y = ~nominal_interest_rate, name = 'nominal interest rate', type="scatter", mode = 'lines+markers',  hoverinfo = 'text', text = ~paste(rownames(df), date, output_gap, exp_inflation, sep="<br>")) %>%
    add_trace(y = ~output_gap, name = 'output gap')  %>%
    add_trace(y = ~exp_inflation, name = "exp inflation")
}
# (3) Monetary policy x Inflation ----
if(ENABLE_3) {
  df <- tail(na.omit(real_data2[,c("date","inflation", "nominal_interest_rate", "output_gap", "q2", "q3", "q4")]),88)
  rownames(df) <- c(1:nrow(df))
  lm1 <- lm(inflation ~ q2 + q3 + q4, df)
  summary(lm1)
  df$inflation_adj <- lm1$residuals
  plot_ly(df, x=~date, y = ~nominal_interest_rate, name = 'nominal interest rate', type="scatter", mode = 'lines+markers',  hoverinfo = 'text', text = ~paste(rownames(df), date, sep="<br>")) %>%
    add_trace(y = ~inflation_adj, name = "inflation season. adj.")
  }

# (4) Other analysis  ----
if(ENABLE_4) {
  # CONTINUE TO ANALYSE WHAT DROVE INTEREST RATES. PAY ATTENTION TO THE BREAK AROUND 2012.
  df$inflation_diff <- c(NA, diff(df$inflation))
  df$exp_inflation_diff <- c(NA, diff(df$exp_inflation))
  df$nominal_interest_rate_diff <- c(NA, diff(df$nominal_interest_rate))
  df$output_gap_diff <- c(NA, diff(df$output_gap))
  
  plot_ly(df, x=~date, y=~inflation_diff, type="scatter", mode="lines")
  adf.test(df$inflation_diff)
  
  plot_ly(df, x=~date, y=~exp_inflation_diff, type="scatter", mode="lines")
  adf.test(df$exp_inflation_diff)
  
  plot_ly(df, x=~date, y=~nominal_interest_rate_diff, type="scatter", mode="lines")
  adf.test(df$nominal_interest_rate_diff)
  
  plot_ly(df, x=~date, y=~output_gap_diff, type="scatter", mode="lines")
  adf.test(df$output_gap_diff)
}
# (5) a VAR for Brazil ----

var_data <- real_data2[,c("inflation", "output_gap", "nominal_interest_rate")]
rownames(var_data) <- real_data2$date
var <- VAR(var_data, p=5)
AIC(var)
summary(var)
serial.test(var, lags.bg = var$p, type="BG")
# SVAR ----
Amat = diag(var$K)
Amat[lower.tri(Amat)] <- NA

svar <- SVAR(var, estmethod = "direct", Amat=Amat, Bmat=NULL, max.iter=1000)
summary(svar)

interestrate_inflation <- irf(svar, impulse="nominal_interest_rate_diff", response="inflation_diff", n.ahead=20)
plot(interestrate_inflation)
outputgap_inflation  <- irf(svar, impulse="output_gap_diff", response="nominal_interest_rate_diff", n.ahead=20)
plot(outputgap_inflation)
inflation_interestrate <- irf(svar, impulse="inflation_diff", response="nominal_interest_rate_diff", n.ahead=20)
plot(inflation_interestrate)
exp_inflation_interestrate <- irf(svar, impulse="exp_inflation_diff", response="nominal_interest_rate_diff", n.ahead=100)
plot(exp_inflation_interestrate)
interestrate_exp_inflation <- irf(svar, impulse="nominal_interest_rate_diff", response="exp_inflation_diff", n.ahead=100)
plot(interestrate_exp_inflation)
# (6) GDP growth: previous year x previous quarter ----
plot_ly(real_data[which(real_data$date > "1995-01-01"),], x=~date, y=~real_gdp_growth_same_quarter_prev_year, name="Previous year", type="scatter", mode="lines") %>%
  add_trace(y=~real_gdp_growth_prev_quarter, name="Previous quarter")
# GDP previous quarter is clearly seasonal

# (7) Checking seasonality ----

# Inflation
lm_inflation <- lm(inflation ~ 0 + q1 + q2 + q3 + q4, real_data_afterReal)
summary(lm_inflation)
pred_inflation <- data.frame(inflation = predict(lm_inflation))
real_data_afterReal$inflation_adj <- real_data_afterReal$inflation - pred_inflation$inflation

ts_inflation <- ts(real_data_afterReal$inflation, start=year(real_data_afterReal$date[1]), deltat = 1/4)
# X12 ARIMA
x12_inflation <- x12(ts_inflation)
real_data_afterReal$inflation_adjx12 <- x12_inflation@d11
lm_inflation_adjx12 <- lm(inflation_adjx12 ~ 0 + q1 + q2 + q3 + q4, real_data_afterReal)
summary(lm_inflation_adjx12)
# Dummies are still significant but it's not an appropriate regression: it should be an ARIMA.

# X12 ARIMA - SEATS
x13_inflation <- seas(ts_inflation, transform.function = "none", regression.aictest = NULL)
summary(x13_inflation)
real_data_afterReal$inflation_adjx13 <- final(x13_inflation)

plot_ly(real_data_afterReal, x=~date, y=~inflation, mode="lines", type="scatter", name="Actual inflation") %>%
  # add_trace(y=pred_inflation$inflation, name="Predicted") %>%
  # add_trace(y=~inflation_adj, name="Adjusted") %>%
  add_trace(y=~inflation_adjx12, name="Adjusted X12") %>%
  add_trace(y=~inflation_adjx13, name="Adjusted X13")

# GDP growth (previous quarter)
lm_gdpgrowth <- lm()
