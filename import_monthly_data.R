while (!require("zoo")) install.packages("zoo")
while (!require("Quandl")) install.packages("Quandl")
while (!require("ecoseries")) install.packages("ecoseries")

# Set up
rm(list = ls())
source("util.R")
Quandl.api_key("iyqies2dKE9mRZpR2zUm")

# Select the series to import
OUTPUT_GAP <- TRUE
INFLATION <- TRUE
INTEREST <- TRUE
EXP_INFLATION <- TRUE
UNCERTAINTY <- TRUE
COMMODITY_INDEX <- TRUE
REAL_EXCHANGE_RATE <- TRUE
IBCBR <- TRUE
INDUSTRIAL_PRODUCTION <- TRUE


data_mon <- data.frame(date = seq(as.Date("1960-01-01"), as.Date("2017-12-01"), "months"), row.names="date")
data_mon$date = rownames(data_mon)
# Import inflation (IBGE, IPCA)
# We download monthly inflation and annualize.
if (INFLATION) {
  inflation <- Quandl("BCB/433")
  inflation$Date <- as.yearmon(inflation$Date)
  rownames(inflation) <- as.Date(inflation$Date)
  # Annualize
  inflation$inflation <- (inflation$Value/100+1)^12-1
  inflation$Value <- NULL
  inflation$Date <- NULL
  data_mon <- merge(data_mon, inflation, by="row.names", all=TRUE)
  rm(inflation)
  rownames(data_mon) <- data_mon$Row.names
  data_mon$date <- rownames(data_mon)
  data_mon$Row.names <- NULL
}

# Import interest rate (Central Bank of Brazil, SELIC)
# The interest rate is computed daily and represents the annual rate.
# We collapse by month and take the current annual interest rate at the end of each month.
if (INTEREST) {
  interest <- data.frame(Quandl("BCB/1178", collapse="monthly", type="raw"))
  rownames(interest) <- as.Date(as.yearmon(interest$Date))
  interest$Date <- NULL
  colnames(interest) <- "nominal_interest_rate"
  interest$nominal_interest_rate <- interest$nominal_interest_rate/100
  data_mon <- merge(data_mon, interest, by="row.names", all=TRUE)
  rm(interest)
  rownames(data_mon) <- data_mon$Row.names
  data_mon$date <- rownames(data_mon)
  data_mon$Row.names <- NULL
}
# Import expected inflation (Central Bank of Brazil, Expected inflation)
# The expected inflation is computed daily and represents the expected inflation for the next 12 months.
# We take the average value for each month
if (EXP_INFLATION) {
  expInfl <- read.csv("real_data/bcb-expected inflation-2001jan-2018fev.csv", colClasses=c("Date", "numeric"))
  expInfl$datemon <- as.yearmon(expInfl$date)
  expInfl <- aggregate(expInfl$"exp_inflation", by=list(expInfl$datemon), "tail", n=1)
  rownames(expInfl) <- as.Date(expInfl$Group.1)
  expInfl$exp_inflation <- expInfl$x/100
  expInfl$Group.1 <- NULL
  expInfl$x <- NULL
  data_mon <- merge(data_mon, expInfl, by="row.names", all=TRUE)
  rm(expInfl)
  rownames(data_mon) <- data_mon$Row.names
  data_mon$date <- rownames(data_mon)
  data_mon$Row.names <- NULL
}

# Calculate real interest rate
if(INTEREST & EXP_INFLATION) {
  data_mon$real_interest_rate <- data_mon$nominal_interest_rate - data_mon$exp_inflation
}

# Import index of uncertainty calculated by FGV (IIE-br) from 2000 to 2018. 
# The index comes in monthly values.
if(UNCERTAINTY) {
  uncertainty <- read.csv("real_data/FGV-uncertainty-IIE-br-2000to2018.csv", skip=1, colClasses = c("character", "numeric"))
  rownames(uncertainty) <- as.Date(as.yearmon(uncertainty$date, format="%m/%Y"))
  uncertainty$date <- NULL
  data_mon <- merge(data_mon, uncertainty, by="row.names", all=TRUE)
  rm(uncertainty)
  rownames(data_mon) <- data_mon$Row.names
  data_mon$date <- rownames(data_mon)
  data_mon$Row.names <- NULL
}

# Downloaded from BCB website; monthly index, seasonally adjusted.
if(IBCBR) {
  ibcbr <- read.csv("real_data/BCB-IBC-br-jan2003-jan2018.csv", skip=2, sep=";", col.names = c("date", "ibcbr"), as.is = TRUE)
  ibcbr <- ibcbr[-nrow(ibcbr),]
  rownames(ibcbr) <- as.Date(as.yearmon(ibcbr$date, format="%m/%Y"))
  ibcbr$ibcbr <- as.numeric(ibcbr$ibcbr)
  ibcbr$date <- NULL
  data_mon <- merge(data_mon, ibcbr, by="row.names", all=TRUE)
  rm(ibcbr)
  rownames(data_mon) <- data_mon$Row.names
  data_mon$date <- rownames(data_mon)
  data_mon$Row.names <- NULL
}

if(REAL_EXCHANGE_RATE) {
  realExR <- data.frame(Quandl("BCB/11752", collapse="monthly", type="raw"))
  rownames(realExR) <- as.Date(as.yearmon(realExR$Date))
  realExR$Date <- NULL
  colnames(realExR) <- "real_ex_rate"
  data_mon <- merge(data_mon, realExR, by="row.names", all=TRUE)
  rm(realExR)
  rownames(data_mon) <- data_mon$Row.names
  data_mon$date <- rownames(data_mon)
  data_mon$Row.names <- NULL 
}

if(COMMODITY_INDEX) {
  commodity_index <- data.frame(Quandl("BCB/20048", collapse="monthly", type="raw"))
  rownames(commodity_index) <- as.Date(as.yearmon(commodity_index$Date))
  commodity_index$Date <- NULL
  colnames(commodity_index) <- "commodity_index"
  data_mon <- merge(data_mon, commodity_index, by="row.names", all=TRUE)
  rm(commodity_index)
  rownames(data_mon) <- data_mon$Row.names
  data_mon$date <- rownames(data_mon)
  data_mon$Row.names <- NULL 
}

# Downloaded CSV from IBGE website. Monthly, % change, seasonally adjusted.
if(INDUSTRIAL_PRODUCTION) {
  ind_prod <- read.csv("real_data/PIM-PF-variacao-percentual-mensal-ajustado-seasonalidade.csv", skip=4, col.names = c("date", "var", "ind_prod"), as.is = TRUE)
  ind_prod <- ind_prod[-nrow(ind_prod),c("date","ind_prod")]
  rownames(ind_prod) <- as.Date(as.yearmon(formatBrazilianMonth(ind_prod$date), format="%m/%Y"))
  ind_prod$date <- NULL
  ind_prod$ind_prod <- as.numeric(ind_prod$ind_prod)/100
  data_mon <- merge(data_mon, ind_prod, by="row.names", all=TRUE)
  rm(ind_prod)
  rownames(data_mon) <- data_mon$Row.names
  data_mon$date <- rownames(data_mon)
  data_mon$Row.names <- NULL  
}

# Save a CSV consolidated with all variables
data_mon$date <- as.Date(data_mon$date)
write.csv(data_mon, "real_data/data_mon.csv", row.names = FALSE)