#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""

Code for my master thesis.

Still under development.

@author: João Dimas (joaohenriqueavila@gmail.com)

"""

class GoodsMarket:

    def __init__(self, economy):
        self.economy = economy
        self.pastInflation = []
        self.prevPrice = None

    def getCurrentInflation(self):
        if self.economy.currentPeriod > 1:
            currentPrice_adj = self.currentPrice / 1e300
            prevPrice_adj = self.prevPrice / 1e300
            return (currentPrice_adj-prevPrice_adj)/prevPrice_adj 
        else:
            return 0

    def getPrevInflation(self):
        return self.pastInflation[-1] if self.economy.currentPeriod > 1 else 0

    def getPastInflationTrend(self):
        if self.economy.currentPeriod <= 2:
            return 0
        
        # We believe there's a mistake in the paper, equation 17. According to the paper, for workers to form their expected inflation, they need the inflation trend at time t (using all PAST AND CURRENT inflation rates, analogous to the formulas for permanent income and smoothed utility).
        # However, before we can calculate current inflation (rate of change in goods' price), we need the result of the whole process from the wage bargain until production. Since expected inflation is an input parameter in the wage bargain function, we can use only past values of inflation to form the trend.
        # Furthermore, we can't calculate inflation at t=1 because we need two periods to get the difference in prices. And we can't calculate at t=1 because we still don't have the current price level.
        summation = 0
        for l in range(len(self.pastInflation)): # l = [0,20]
            summation = summation + self.economy.parameters.Ro ** (l) * self.pastInflation[-l-1]
            assert l != 19 or self.pastInflation[-l-1] == self.pastInflation[0]

        return (1-self.economy.parameters.Ro)*summation

    def matchFirmAndConsumers(self):
        self.currentPrice = self.economy.firm.getSellingPrice()
        #Logger.trace("[Goods market] Matching firms and workers. Price of good: {:.2f}.", self.currentPrice, economy=self.economy)
        suppliedGoods = self.economy.firm.getProduction()
        #Logger.trace("[Goods market] Firm produced {:.2f} units.", suppliedGoods, economy=self.economy)
        households = sorted(self.economy.households, key=lambda hh: hh.getConsumptionDemand(), reverse=True)
        #Logger.trace("[Goods market] Firm sorted households by demand.", economy=self.economy)

        soldGoods = 0
        """ Equation (20) """
        #Logger.trace("[Goods market] Firm is iterating households.", economy=self.economy)
        for hh in households:
            #Logger.trace("[Goods market] Household {:d} wants to buy {:.2f} goods. Goods sold so far: {:.2f}. Supplied goods: {:.2f}.", (hh.householdId, hh.getConsumptionDemand(), soldGoods, suppliedGoods), economy=self.economy)
            if soldGoods >= suppliedGoods:
                #Logger.trace("[Goods market] No goods available for household {:d}. He buys nothing.", hh.householdId, economy=self.economy)
                hh.effectivelyConsumedGoods = 0
                continue

            soldGoods = soldGoods + hh.getConsumptionDemand()
            hh.effectivelyConsumedGoods = hh.getConsumptionDemand()

            # what about excess demand of the last buying household?
            if soldGoods > suppliedGoods:
                excess = soldGoods - suppliedGoods
                hh.effectivelyConsumedGoods = hh.effectivelyConsumedGoods - excess
                soldGoods = suppliedGoods
                #Logger.trace("[Goods market] Household {:d} wants {:.2f} but only {:.2f} are available, so he buys less than desired.", (hh.householdId, hh.getConsumptionDemand(), hh.getConsumptionDemand()-excess), economy=self.economy)

            #Logger.trace("[Goods market] Household {:d} buys {:.2f} goods.", (hh.householdId, hh.effectivelyConsumedGoods), economy=self.economy)
        self.aggregateConsumption = soldGoods
        #Logger.trace("[Goods market] Finished matching firms and buyers. Goods sold: {:.2f}", soldGoods, economy=self.economy)

    def nextPeriod(self):
        """ Prepare the object for a clean next period """

        self.pastInflation.append(self.getCurrentInflation())
        self.pastInflation = self.pastInflation[-self.economy.parameters.InflationWindowOfObservation:]
        if self.economy.currentPeriod > self.economy.parameters.InflationWindowOfObservation:
            assert len(self.pastInflation) == self.economy.parameters.InflationWindowOfObservation, "len(self.pastPrices) = {:d}".format(len(self.pastPrices))
        else:
            len(self.pastInflation) == self.economy.currentPeriod
            
        self.prevPrice = self.currentPrice
        self.currentPrice = None
