table.begin <- "\\begin{columns}
\\column{0.6\\textwidth}
\\scalebox{0.5}{
{
\\def\\sym#1{\\ifmmode^{#1}\\else\\(^{#1}\\)\\fi}
\\begin{tabular}{l*{3}{c}}
    \\hline\\hline
    &\\multicolumn{1}{c}{(1)}    &\\multicolumn{1}{c}{(2)}    &\\multicolumn{1}{c}{(3)} \\\\ \\hline
    &                           &                                                    \\\\\n\n"

variable.labels <- data.frame(c("External Debt in percent of GDP",
                                          "External Debt Service in percent of Exports",
                                          "International Reserves in percent of GDP",
                                          "Reserves Growth",
                                          "Current Account in percent of GDP",
                                          "Export Growth",
                                          "Trade Openness Index",
                                          "Real GDP Growth",
                                          "Inflation",
                                          "Government Expenditures Growth",
                                          "US Imports Share",
                                          "Elections"),
                              row.names = c("debt", "service", "reserves", "reserves_growth", "CA", "exp_growth", "trade_openness", "rgdp", "inflation", "gov_exp", "us_share", "elections"))


regression_variable_prefix <- "linear.panel."
table.middle <- ""
variable_list <- names(linear.panel.3$coefficients)
for(variable in variable_list) {
  line <- variable.labels[variable,1]
  for(p in c(1:3)) {
    panel <- get(paste0(regression_variable_prefix,p))  
    coefficient <- panel$coefficients[variable]
    line <- paste(line, " \t& ")
    if(!is.na(coefficient)) {
      stars <- ifelse(panel$summary$coefficients[variable,4]<0.01,"\\sym{***}", ifelse(panel$summary$coefficients["service",4]<0.05,"\\sym{**}", ifelse(panel$summary$coefficients["service",4]<0.1,"\\sym{*}","")))
      line <- paste0(line, sprintf(coefficient[[1]], fmt="%.3f"), stars) 
    }
  }
  table.middle <- paste(table.middle, line, sep="\t\\\\ [1em] \n ")
}
table.middle <- paste(table.middle, "\\\\ \\hline \n")
table.middle <- paste(table.middle, "Country fixed effects & Yes & Yes & Yes \t\\\\ \n")
table.middle <- paste(table.middle, "Time fixed effects & Yes & Yes & Yes \t\\\\ \n")
table.middle <- paste(table.middle, "\\hline \n")




table.end <- paste("    \\(N\\)                                           &", nrow(linear.panel.1$model) ,"                       &       &              \\\\
    \\hline\\hline
\\end{tabular}}
}

\\column{0.25\\textwidth}

\\tiny{\\flushright{1/ Logit regression with robust variance estimates, allowing for country-specific variances (Huber White sandwich estimator)}}
\\tiny{\\flushright{2/ Marginal Effects calculated at mean, for dummy at switch from 0 to 1}}
\\tiny{\\flushright{3/ Variables lagged to account for reverse causality}}
\\tiny{\\flushright{4/ Significance: *** 0.01 ** 0.05 * 0.10}}
\\end{columns}
")

cat(paste(table.begin, table.middle, table.end))