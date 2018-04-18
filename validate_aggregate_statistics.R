
agg <- read.csv("data/ABMNK.LAST[Sce_1]AggregateStatistics.csv", row.names=1)
results <- c()
for(exp in c(17)) {
  for(sim in c(1:10)) {
    results <- rbind(read.csv(paste0("data/ABMNK.LAST[Sce_1][Exp_",exp,"][Sim_",sim,"]GranularData.csv")), results)
  }
}
results$inflation_gap <- results$inflation - results$inflation_target

for(var in colnames(agg)) {
  var <- "inflation_gap"
  print(mean(results[,var]) == agg["mean", var])
  stopifnot(mean(results[,var]) == agg["mean", var])
}