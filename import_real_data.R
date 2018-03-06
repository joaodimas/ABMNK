while (!require("zoo")) install.packages("zoo")
while (!require("Quandl")) install.packages("Quandl")

# Set up
rm(list = ls())
setwd("/Users/jdimas/GitHub/ABMNK/real_data")
Quandl.api_key("iyqies2dKE9mRZpR2zUm")

# Import Output Gap (IPEA)
data <- read.csv("ipea-CC37_Produto-Potencial-trimestral-1993t1-2017t3.csv", sep=";", skip=5, header=FALSE, col.names=c("date", "pot_gdp", "real_gdp", "output_gap", "X1", "X2", "X3", "X4"))
data <- data[,c("date","output_gap")]
data$date <- as.yearqtr(data$date, format="%Y T%q")
rownames(data) <- data$date
data$output_gap <- as.numeric(gsub('%', '', data$output_gap))/100

# Import inflation (Central Bank of Brazil, IPCA)
# We download monthly inflation, aggregate by quarter, and then we annualize.
# As a result we have annualized quarterly inflation.
inflation <- Quandl("BCB/433")
inflation$Date <- as.yearqtr(inflation$Date)
# Aggregate by quarter
inflation <- aggregate(inflation$Value/100+1, by=list(inflation$Date), "prod")
# Annualize
inflation$inflation <- (inflation$x^4)-1
rownames(inflation) <- inflation$Group.1
inflation$Group.1 <- NULL
inflation$x <- NULL
data <- merge(data, inflation, by="row.names", all=TRUE)
rm(inflation)
rownames(data) <- data$Row.names
data$date <- rownames(data)
data$Row.names <- NULL

# Import interest rate (Central Bank of Brazil, SELIC)
# The interest rate is computed daily and represents the annual rate.
# We collapse by quarter and take the current annual interest rate at the end of each quarter.
interest <- data.frame(Quandl("BCB/1178", collapse="quarterly", type="zoo"))
colnames(interest) <- "interest"
data <- merge(data, interest, by="row.names", all=TRUE)
rm(interest)
rownames(data) <- data$Row.names
data$date <- rownames(data)
data$Row.names <- NULL

# Import expected inflation (Central Bank of Brazil, Expected inflation)
# The expected inflation is computed daily and represents the expected inflation for the next 12 months.
# We take the last value for each quarter.
expInfl <- read.csv("bcb-expected inflation-2001jan-2018fev.csv", colClasses=c("Date", "numeric"))
expInfl$dateqtr <- as.yearqtr(expInfl$date)
expInfl <- aggregate(expInfl$"exp_inflation", by=list(expInfl$dateqtr), "tail", n=1)
rownames(expInfl) <- expInfl$Group.1
expInfl$exp_inflation <- expInfl$x
expInfl$Group.1 <- NULL
expInfl$x <- NULL
data <- merge(data, expInfl, by="row.names", all=TRUE)
rm(expInfl)
rownames(data) <- data$Row.names
data$date <- rownames(data)
data$Row.names <- NULL

# Import GDP deflator (Central Bank of Brazil, GDP deflator, yearly)
gdpDeflator <- data.frame(Quandl("BCB/1211", collapse="quarterly", type="zoo"))
colnames(gdpDeflator) <- "bcb_gdp_deflator"
data <- merge(data, gdpDeflator, by="row.names", all=TRUE)
rm(gdpDeflator)
rownames(data) <- data$Row.names
data$date <- rownames(data)
data$Row.names <- NULL

# Import GDP components (IMF International Financial Statistics (IFS), Brazil, from 2013Q1 to 2017Q3, http://data.imf.org/regular.aspx?key=61545852)
gdpComp <- read.csv("International_Financial_Statistics.csv", skip=1, sep=";")
gdpComp$date <- as.yearqtr(gdpComp$date, format="Q%q %Y")
for (i in 2:12) {
  gdpComp[,i] <- as.numeric(gsub(',', '', gdpComp[,i]))
  if (i <= 9) {
    gdpComp[,i] <- gdpComp[,i]*1000000
  }
  if (i == 11 | i == 12) {
    gdpComp[,i] <- gdpComp[,i]/100
  }
}
rownames(gdpComp) <- gdpComp$date
gdpComp$date <- NULL
data <- merge(data, gdpComp, by="row.names", all=TRUE)
rm(gdpComp)
rownames(data) <- data$Row.names
data$date <- rownames(data)
data$Row.names <- NULL



# Save a CSV consolidated with all variables
data$date <- as.Date(as.yearqtr(as.character(data$date)))
write.csv(data, "data.csv", row.names = FALSE)