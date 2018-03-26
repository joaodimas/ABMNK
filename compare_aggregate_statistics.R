rm(list = ls())

file_prefix <- "ABMNK.2018-03-25T20h02m30s"
folder_prefix <- "20180325"


setwd(paste0("~/GitHub/ABMNK/", folder_prefix, "_data/"))

result <- data.frame()
for(scenario in c(1:5)) {
  df <- read.csv(paste0(file_prefix,"[Sce_",scenario,"]AggregateStatistics.csv"), row.names = 1)
  result["inflation_gap_mean", paste0("sce_",scenario)] <- df["mean", "inflation_gap"]
  result["inflation_gap_stdev", paste0("sce_",scenario)] <- df["stdev", "inflation_gap"]
  result["unemployment_rate_mean", paste0("sce_",scenario)] <- df["mean", "unemployment_rate"]
  result["unemployment_rate_stdev", paste0("sce_",scenario)] <- df["stdev", "unemployment_rate"]
  result["mean_indexation_strategy_mean", paste0("sce_",scenario)] <- df["mean", "mean_indexation_strategy"]
  result["mean_indexation_strategy_stdev", paste0("sce_",scenario)] <- df["stdev", "mean_indexation_strategy"]
  result["mean_substitution_strategy_mean", paste0("sce_",scenario)] <- df["mean", "mean_substitution_strategy"]
  result["mean_substitution_strategy_stdev", paste0("sce_",scenario)] <- df["stdev", "mean_substitution_strategy"]
  result["var_indexation_strategy_mean", paste0("sce_",scenario)] <- df["mean", "stdev_indexation_strategy"]^2
  result["var_indexation_strategy_stdev", paste0("sce_",scenario)] <- df["stdev", "stdev_indexation_strategy"]^2
  result["var_substitution_strategy_mean", paste0("sce_",scenario)] <- df["mean", "stdev_substitution_strategy"]^2
  result["var_substitution_strategy_stdev", paste0("sce_",scenario)] <- df["stdev", "stdev_substitution_strategy"]^2
}

write.csv(result, "Paper_AggregateData.csv")

