while (!require("zoo")) install.packages("zoo")
while (!require("Quandl")) install.packages("Quandl")

# Set up
rm(list = ls())
setwd("/Users/jdimas/GitHub/ABMNK/real_data")
Quandl.api_key("iyqies2dKE9mRZpR2zUm")

# Select the series to import
OUTPUT_GAP <- TRUE
INFLATION <- TRUE
INTEREST <- TRUE
EXP_INFLATION <- TRUE
BCB_GDP_DEFLATOR <- FALSE
UNCERTAINTY <- TRUE
QUARTER_DUMMIES <- TRUE
IMF_FINANCIAL_STATS <- TRUE
IBCBR <- TRUE

# Select the first year in the series
INITIAL_YEAR <- 1960


date <- as.yearqtr(INITIAL_YEAR + seq(0, 235)/4)
data <- data.frame(date, row.names="date")

# Import Output Gap (IPEA)
if (OUTPUT_GAP) {
  outputGap <- read.csv("ipea-CC37_Produto-Potencial-trimestral-1993t1-2017t3.csv", sep=";", skip=5, header=FALSE, col.names=c("date", "pot_gdp", "real_gdp", "output_gap", "X1", "X2", "X3", "X4"))
  outputGap <- outputGap[,c("date","output_gap")]
  outputGap$date <- as.yearqtr(outputGap$date, format="%Y T%q")
  rownames(outputGap) <- outputGap$date
  outputGap$output_gap <- as.numeric(gsub('%', '', outputGap$output_gap))/100
  data <- merge(data, outputGap, by="row.names", all=TRUE)
  rm(outputGap)
  rownames(data) <- data$Row.names
  data$date <- rownames(data)
  data$Row.names <- NULL
}

# Import inflation (Central Bank of Brazil, IPCA)
# We download monthly inflation, aggregate by quarter, and then we annualize.
# As a result we have annualized quarterly inflation.
if (INFLATION) {
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
}

# Import interest rate (Central Bank of Brazil, SELIC)
# The interest rate is computed daily and represents the annual rate.
# We collapse by quarter and take the current annual interest rate at the end of each quarter.
if (INTEREST) {
  interest <- data.frame(Quandl("BCB/1178", collapse="quarterly", type="zoo"))
  colnames(interest) <- "nominal_interest_rate"
  interest$nominal_interest_rate <- interest$nominal_interest_rate/100
  data <- merge(data, interest, by="row.names", all=TRUE)
  rm(interest)
  rownames(data) <- data$Row.names
  data$date <- rownames(data)
  data$Row.names <- NULL
}
# Import expected inflation (Central Bank of Brazil, Expected inflation)
# The expected inflation is computed daily and represents the expected inflation for the next 12 months.
# We take the last value for each quarter.
if (EXP_INFLATION) {
  expInfl <- read.csv("bcb-expected inflation-2001jan-2018fev.csv", colClasses=c("Date", "numeric"))
  expInfl$dateqtr <- as.yearqtr(expInfl$date)
  expInfl <- aggregate(expInfl$"exp_inflation", by=list(expInfl$dateqtr), "tail", n=1)
  rownames(expInfl) <- expInfl$Group.1
  expInfl$exp_inflation <- expInfl$x/100
  expInfl$Group.1 <- NULL
  expInfl$x <- NULL
  data <- merge(data, expInfl, by="row.names", all=TRUE)
  rm(expInfl)
  rownames(data) <- data$Row.names
  data$date <- rownames(data)
  data$Row.names <- NULL
}

# Calculate real interest rate
if(INTEREST & EXP_INFLATION) {
  data$real_interest_rate <- data$nominal_interest_rate - data$exp_inflation
}

# Import GDP deflator (Central Bank of Brazil, GDP deflator, yearly)
if (BCB_GDP_DEFLATOR) {
  gdpDeflator <- data.frame(Quandl("BCB/1211", collapse="quarterly", type="zoo"))
  colnames(gdpDeflator) <- "bcb_gdp_deflator"
  data <- merge(data, gdpDeflator, by="row.names", all=TRUE)
  rm(gdpDeflator)
  rownames(data) <- data$Row.names
  data$date <- rownames(data)
  data$Row.names <- NULL
}

# Import index of uncertainty calculated by FGV (IIE-br) from 2000 to 2018. 
# The index comes in monthly values. I keep the last month of each quarter.
if(UNCERTAINTY) {
  uncertainty <- read.csv("FGV-uncertainty-IIE-br-2000to2018.csv", skip=1, colClasses = c("character", "numeric"))
  uncertainty$date <- as.yearqtr(uncertainty$date, format="%m/%Y")
  uncertainty <- aggregate(uncertainty$uncertainty, by=list(uncertainty$date), "tail", n=1)
  rownames(uncertainty) <- uncertainty$Group.1
  uncertainty$uncertainty <- uncertainty$x
  uncertainty$Group.1 <- NULL
  uncertainty$x <- NULL
  data <- merge(data, uncertainty, by="row.names", all=TRUE)
  rm(uncertainty)
  rownames(data) <- data$Row.names
  data$date <- rownames(data)
  data$Row.names <- NULL
}

if(IBCBR) {
  ibcbr <- read.csv("bcb-IBC-br-monthly-2003to2017.csv", skip=1, colClasses = c("character", "numeric"))
  ibcbr$date <- as.yearqtr(ibcbr$date, format="%d/%m/%Y")
  ibcbr <- aggregate(ibcbr$ibcbr, by=list(ibcbr$date), "tail", n=1)
  rownames(ibcbr) <- ibcbr$Group.1
  ibcbr$ibcbr <- ibcbr$x
  ibcbr$Group.1 <- NULL
  ibcbr$x <- NULL
  data <- merge(data, ibcbr, by="row.names", all=TRUE)
  rm(ibcbr)
  rownames(data) <- data$Row.names
  data$date <- rownames(data)
  data$Row.names <- NULL
}

# Import several variables (IMF International Financial Statistics (IFS), Brazil, from 1990Q1 to 2017Q4, http://data.imf.org/regular.aspx?key=61545852)
if (IMF_FINANCIAL_STATS) {
  imfFinStats <- read.csv("International_Financial_Statistics.csv", skip=1, sep=";")
  imfFinStats$date <- as.yearqtr(imfFinStats$date, format="Q%q %Y")
  for (i in 2:12) {
    imfFinStats[,i] <- as.numeric(gsub(',', '', imfFinStats[,i]))
    if (i <= 9) {
      imfFinStats[,i] <- imfFinStats[,i]*1000000
    }
    if (i == 11 | i == 12) {
      imfFinStats[,i] <- imfFinStats[,i]/100
    }
  }
  rownames(imfFinStats) <- imfFinStats$date
  imfFinStats$date <- NULL
  data <- merge(data, imfFinStats, by="row.names", all=TRUE)
  rm(imfFinStats)
  rownames(data) <- data$Row.names
  data$date <- rownames(data)
  data$Row.names <- NULL
}

if(QUARTER_DUMMIES) {
  for(q in 2:4) {
    data[grep(paste0("Q",q), data$date, fixed=TRUE),paste0("q",q)] <- 1
    data[-grep(paste0("Q",q), data$date, fixed=TRUE),paste0("q",q)] <- 0
  } 
}

# Save a CSV consolidated with all variables
data$date <- as.Date(as.yearqtr(as.character(data$date)))
write.csv(data, "data.csv", row.names = FALSE)