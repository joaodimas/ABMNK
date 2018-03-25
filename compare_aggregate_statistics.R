rm(list = ls())

setwd("~/GitHub/ABMNK/20180324_data/")
prefix <- "ABMNK.2018-03-24T16h44m44s"

result <- data.frame(row.names = c("inflation_gap", "unemployment_rate", "mean_indexation_strategy", "mean_substitution_strategy", "var_indexation_strategy", "var_substitution_strategy"))
for(scenario in c(1:5)) {
  df <- read.csv(paste0(prefix,"[Sce_",scenario,"]AggregateStatistics.csv"), row.names = 1)
  result["inflation_gap", paste0("sce_",scenario)] <- df["mean", "inflation_gap"]
  result["unemployment_rate", paste0("sce_",scenario)] <- df["mean", "unemployment_rate"]
  result["mean_indexation_strategy", paste0("sce_",scenario)] <- df["mean", "mean_indexation_strategy"]
  result["mean_substitution_strategy", paste0("sce_",scenario)] <- df["mean", "mean_substitution_strategy"]
  result["var_indexation_strategy", paste0("sce_",scenario)] <- df["mean", "stdev_indexation_strategy"]^2
  result["var_substitution_strategy", paste0("sce_",scenario)] <- df["mean", "stdev_substitution_strategy"]^2
}

