while (!require("plotly")) install.packages("plotly")
while (!require("tseries")) install.packages("tseries")
while (!require("vars")) install.packages("vars")
while (!require("strucchange")) install.packages("strucchange")
while (!require("ecm")) install.packages("ecm")

# Initial import ----------------------------------------------------------
rm(list = ls())
setwd("/Users/jdimas/GitHub/ABMNK/real_data")
data <- read.csv("data.csv", colClasses=c("Date", rep("numeric", 21)))

# Monetary policy responding to expected inflation ------------------------

df <- na.omit(data[,c("date", "exp_inflation", "nominal_interest_rate", "real_interest_rate")])
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
lm4 <- summary(lm(real_interest_rate ~ exp_inflation, df))
print(paste("lm1 R2: ",lm1$r.squared))
print(paste("lm2 R2: ",lm2$r.squared))
print(paste("lm3 R2: ",lm3$r.squared))
print(paste("lm4 R2: ",lm4$r.squared))
# Highest R2 is nominal_interest_rate ~ exp_inflation lagged.

breakpoints(nominal_interest_rate ~ lagpad(exp_inflation,1), data=df)$breakpoints
# Breakpoints at observation number: 18 28 41 54 
breakpoints(real_interest_rate ~ lagpad(exp_inflation,1), data=df)$breakpoints
# Breakpoints at observation number: 19 28 41 54 

# Monetary policy x Output gap and expected inflation ---------

df <- na.omit(data[,c("date", "nominal_interest_rate", "real_interest_rate", "output_gap", "exp_inflation", "inflation")])
rownames(df) <- c(1:nrow(df))
plot_ly(df, x=~date, y = ~nominal_interest_rate, name = 'nominal interest rate', type="scatter", mode = 'lines+markers',  hoverinfo = 'text', text = ~paste(rownames(df), date, output_gap, exp_inflation, sep="<br>")) %>%
  add_trace(y = ~output_gap, name = 'output gap')  %>%
  add_trace(y = ~exp_inflation, name = "exp inflation")

# Monetary policy x Inflation ---------------------------------

df <- tail(na.omit(data[,c("date","inflation", "nominal_interest_rate", "output_gap", "q2", "q3", "q4")]),88)
rownames(df) <- c(1:nrow(df))
lm1 <- lm(inflation ~ q2 + q3 + q4, df)
summary(lm1)
df$inflation_adj <- lm1$residuals
plot_ly(df, x=~date, y = ~nominal_interest_rate, name = 'nominal interest rate', type="scatter", mode = 'lines+markers',  hoverinfo = 'text', text = ~paste(rownames(df), date, sep="<br>")) %>%
  add_trace(y = ~inflation_adj, name = "inflation season. adj.")


# Other analysis  ---------------------------------------------------------

# CONTINUE TO ANALYSE WHAT DROVE INTEREST RATES. PAY ATTENTION TO THE BREAK AROUND 2012.
df$inflation_diff <- c(0, diff(df$inflation))
df$exp_inflation_diff <- c(0, diff(df$exp_inflation))
df$nominal_interest_rate_diff <- c(0, diff(df$nominal_interest_rate))
df$output_gap_diff <- c(0, diff(df$output_gap))

plot_ly(df, x=~date, y=~inflation_diff, type="scatter", mode="lines")
adf.test(df$inflation_diff)

plot_ly(df, x=~date, y=~exp_inflation_diff, type="scatter", mode="lines")
adf.test(df$exp_inflation_diff)

plot_ly(df, x=~date, y=~nominal_interest_rate_diff, type="scatter", mode="lines")
adf.test(df$nominal_interest_rate_diff)

plot_ly(df, x=~date, y=~output_gap_diff, type="scatter", mode="lines")
adf.test(df$output_gap_diff)


var <- VAR(df[,c("inflation_diff", "output_gap_diff", "nominal_interest_rate_diff", "exp_inflation_diff")], lag.max=4, ic="AIC")
summary(var)

Amat = diag(4)
Amat[2,1] <- NA
Amat[3,1] <- NA
Amat[3,2] <- NA
Amat[4,1] <- NA
Amat[4,2] <- NA
Amat[4,3] <- NA
# 1 0 0 0
# NA 1 0 0
# NA NA 1 0
# NA NA NA 1 
svar <- SVAR(var, estmethod = "direct", Amat=Amat, Bmat=NULL, max.iter=1000)
summary(svar)
svar
interestrate_inflation <- irf(svar, impulse="nominal_interest_rate_diff", response="inflation_diff", n.ahead=100)
plot(interestrate_inflation)
outputgap_inflation  <- irf(svar, impulse="output_gap_diff", response="nominal_interest_rate_diff", n.ahead=100)
plot(outputgap_inflation)
inflation_interestrate <- irf(svar, impulse="inflation_diff", response="nominal_interest_rate_diff", n.ahead=100)
plot(inflation_interestrate)
exp_inflation_interestrate <- irf(svar, impulse="exp_inflation_diff", response="nominal_interest_rate_diff", n.ahead=100)
plot(exp_inflation_interestrate)
interestrate_exp_inflation <- irf(svar, impulse="nominal_interest_rate_diff", response="exp_inflation_diff", n.ahead=100)
plot(interestrate_exp_inflation)
