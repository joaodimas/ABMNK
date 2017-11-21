# -*- coding: utf-8 -*-
"""
Project for course Quantitative Methods in Finance, Prof. Eric Vansteenberghe.
Université Paris 1 Panthéon-Sorbonne
Program: Master 2 Financial Economics, 2017.
Authors: João Dimas (joaohenriqueavila@gmail.com) and Umberto Collodel (umberto.collodel@gmail.com)

Replication of an agent-based model described in:
Salle, I., Yıldızoğlu, M., & Sénégas, M.-A. (2013). Inflation targeting in a learning economy: An ABM perspective. Economic Modelling, 34, 114–128.

Technical information on README.md

"""

from model.parameters import Parameters
import statistics

class ResultsData:

    @classmethod
    def getCurrentPeriodData(cls, economy):
        return [
                economy.scenario,
                economy.experiment,
                economy.run,
                economy.currentPeriod,
                economy.goodsMarket.getCurrentInflation(),
                Parameters.InflationTarget,
                economy.labourMarket.getUnemploymentRate(),
                statistics.mean([hh.indexationStrategy for hh in economy.households]),
                statistics.mean([hh.substitutionStrategy for hh in economy.households]),
                statistics.variance([hh.indexationStrategy for hh in economy.households]),
                statistics.variance([hh.substitutionStrategy for hh in economy.households])
                ]

    @classmethod
    def getHeader(cls):
        return ["scenario", "experiment", "run", "period", "inflation", "inflation_target", "unemployment_rate", "mean_indexation_strategy", "mean_substitution_strategy", "var_indexation_strategy", "var_substitution_strategy"]

    @classmethod
    def getAggregateStatistics(cls, resultsdata, scenario):
        result = [["scenario", "statistic", "inflation_gap", "unemployment", "mean_indexation_strategy", "mean_substitution_strategy", "var_indexation_strategy", "var_substitution_strategy"]]

        resultsdata = resultsdata[1:]
        # Mean
        result.append([
                    scenario,
                    "mean",
                    statistics.mean([d[4] - d[5] for d in resultsdata]), # inflation gap
                    statistics.mean([d[6] for d in resultsdata]), # unemployment
                    statistics.mean([d[7] for d in resultsdata]), # mean_indexation_strategy
                    statistics.mean([d[8] for d in resultsdata]), # mean_substitution_strategy
                    statistics.mean([d[9] for d in resultsdata]), # var_indexation_strategy
                    statistics.mean([d[10] for d in resultsdata]) # var_substitution_strategy
                ])

        # Std. Deviation
        result.append([
                    scenario,
                    "stddev",
                    statistics.stdev([d[4] - d[5] for d in resultsdata]), # inflation gap
                    statistics.stdev([d[6] for d in resultsdata]), # unemployment
                    statistics.stdev([d[7] for d in resultsdata]), # mean_indexation_strategy
                    statistics.stdev([d[8] for d in resultsdata]), # mean_substitution_strategy
                    statistics.stdev([d[9] for d in resultsdata]), # var_indexation_strategy
                    statistics.stdev([d[10] for d in resultsdata]) # var_substitution_strategy
                ])

        return result
