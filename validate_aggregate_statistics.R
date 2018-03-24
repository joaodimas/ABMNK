setwd("~/GitHub/ABMNK/data/")

agg <- read.csv("ABMNK.LAST[Sce_1]AggregateStatistics.csv", row.names=1)
results <- c()
for(exp in c(17)) {
  for(sim in c(1:10)) {
    results <- rbind(read.csv(paste0("ABMNK.LAST[Sce_1][Exp_",exp,"][Sim_",sim,"]GranularData.csv")), results)
  }
}
results$inflation_gap <- results$inflation - results$inflation_target

for(var in colnames(agg)) {
  var <- "inflation_gap"
  print(mean(results[,var]) == agg["mean", var])
  stopifnot(mean(results[,var]) == agg["mean", var])
}



# exp1sim1 <- read.csv("ABMNK.LAST[Sce_1][Exp_1][Sim_1]GranularData.csv")
# exp1sim1$inflation_gap <- exp1sim1$inflation - exp1sim1$inflation_target
# exp1sim2 <- read.csv("ABMNK.LAST[Sce_1][Exp_1][Sim_2]GranularData.csv")
# exp1sim2$inflation_gap <- exp1sim2$inflation - exp1sim2$inflation_target
# exp2sim1 <- read.csv("ABMNK.LAST[Sce_1][Exp_2][Sim_1]GranularData.csv")
# exp2sim1$inflation_gap <- exp2sim1$inflation - exp2sim1$inflation_target
# exp2sim2 <- read.csv("ABMNK.LAST[Sce_1][Exp_2][Sim_2]GranularData.csv")
# exp2sim2$inflation_gap <- exp2sim2$inflation - exp2sim2$inflation_target
# agg <- read.csv("ABMNK.LAST[Sce_1]AggregateStatistics.csv", row.names=1)
# 
# 
# for(var in colnames(agg)) {
#   gra <- c(exp1sim1[,var], exp1sim2[,var], exp2sim1[,var], exp2sim2[,var])
#   print(mean(gra) == agg["mean", var])
#   stopifnot(mean(gra) == agg["mean", var])
# }
