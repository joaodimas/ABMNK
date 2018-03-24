# -*- coding: utf-8 -*-
"""

Code for my master thesis.

Still under development.

@author: João Dimas (joaohenriqueavila@gmail.com)

"""

import statistics

class ResultsData:

    @classmethod
    def getCurrentPeriodData(cls, economy):
        
        return [
                economy.parameters.Experiment,
                economy.simulationNumber,
                economy.currentPeriod,
                economy.goodsMarket.getCurrentInflation(),
                economy.parameters.InflationTarget,
                economy.nominalInterestRate,
                economy.getMeanExpectedInflation(),
                economy.nominalInterestRate - economy.getMeanExpectedInflation(),
                economy.labourMarket.getUnemploymentRate(),
                economy.getOutputGap(),
                economy.goodsMarket.aggregateConsumption,
                economy.labourMarket.getRealWageRate(),
                economy.getMeanRealSavingsBalance(),
                economy.getMeanIndexationStrategy(),
                economy.getMeanSubstitutionStrategy(),
                economy.getStDevRealSavingsBalance(),
                economy.getStDevIndexationStrategy(),
                economy.getStDevSubstitutionStrategy(),
                ]

    @classmethod
    def getHeader(cls):
        return ["experiment", "simulation_number", "period", "inflation", "inflation_target", "nominal_interest_rate", "mean_exp_inflation", "real_interest_rate", "unemployment_rate", "output_gap", "consumption", "real_wage_rate", "mean_real_savings_balance", "mean_indexation_strategy", "mean_substitution_strategy", "stdev_real_savings_balance", "stdev_indexation_strategy", "stdev_substitution_strategy"]

    @classmethod
    def getAverageGranularData(cls, resultsdata):
        header = []
        for h in cls.getHeader():
            if h != "simulation_number":
                header.append(h)
                
        averageGranularData = [header]
        variables = len(header)-1
        periods = len(resultsdata[0])
        simulations = len(resultsdata)
        
        for t in range(periods):
            periodAverages = [t+1]
            for v in range(variables):
                varSum = 0
                for s in range(simulations):
                    varSum = varSum + resultsdata[s][t][v+2]
                periodAverages.append(varSum/simulations)
            averageGranularData.append(periodAverages)
            
        return averageGranularData

    @classmethod
    def getAggregateStatistics(cls, granular_data):
        header_aggregate = ["statistic", "inflation_gap", "nominal_interest_rate", "unemployment_rate", "mean_real_savings_balance", "mean_indexation_strategy", "mean_substitution_strategy", "stdev_real_savings_balance", "stdev_indexation_strategy", "stdev_substitution_strategy"]

        header_granular = cls.getHeader()
        
        result = [header_aggregate]
        # Mean
        result.append([
                    "mean",
                    statistics.mean([d[header_granular.index("inflation")] - d[header_granular.index("inflation_target")] for d in granular_data]), # inflation gap
                    statistics.mean([d[header_granular.index("nominal_interest_rate")] for d in granular_data]), # interest rate
                    statistics.mean([d[header_granular.index("unemployment_rate")] for d in granular_data]), # unemployment
                    statistics.mean([d[header_granular.index("mean_real_savings_balance")] for d in granular_data]), # mean_real_savings_balance
                    statistics.mean([d[header_granular.index("mean_indexation_strategy")] for d in granular_data]), # mean_indexation_strategy
                    statistics.mean([d[header_granular.index("mean_substitution_strategy")] for d in granular_data]), # mean_substitution_strategy
                    statistics.mean([d[header_granular.index("stdev_real_savings_balance")] for d in granular_data]), # stdev_savings_balance
                    statistics.mean([d[header_granular.index("stdev_indexation_strategy")] for d in granular_data]), # stdev_indexation_strategy
                    statistics.mean([d[header_granular.index("stdev_substitution_strategy")] for d in granular_data]) # stdev_substitution_strategy
                ])

        # Std. Deviation
        result.append([
                    "stdev",
                    statistics.stdev([d[header_granular.index("inflation")] - d[header_granular.index("inflation_target")] for d in granular_data]), # inflation gap
                    statistics.stdev([d[header_granular.index("nominal_interest_rate")] for d in granular_data]), # interest rate
                    statistics.stdev([d[header_granular.index("unemployment_rate")] for d in granular_data]), # unemployment
                    statistics.stdev([d[header_granular.index("mean_real_savings_balance")] for d in granular_data]), # stdev_real_savings_balance
                    statistics.stdev([d[header_granular.index("mean_indexation_strategy")] for d in granular_data]), # stdev_indexation_strategy
                    statistics.stdev([d[header_granular.index("mean_substitution_strategy")] for d in granular_data]), # stdev_substitution_strategy
                    statistics.stdev([d[header_granular.index("stdev_real_savings_balance")] for d in granular_data]), # stdev_savings_balance
                    statistics.stdev([d[header_granular.index("stdev_indexation_strategy")] for d in granular_data]), # stdev_indexation_strategy
                    statistics.stdev([d[header_granular.index("stdev_substitution_strategy")] for d in granular_data]) # stdev_substitution_strategy
                ])

        return result
