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
            return (self.currentPrice-self.prevPrice)/self.prevPrice
        else:
            return 0

    def getPrevInflation(self):
        return self.pastInflation[-1] if self.economy.currentPeriod > 1 else self.economy.parameters.InitialInflation

    def getPastInflationTrend(self):
        if self.economy.currentPeriod <= 2:
            return self.economy.parameters.InitialInflation
        
        # We believe there's a mistake in the paper, equation 17. According to the paper, for workers to form their expected inflation, they need the inflation trend at time t (using all PAST AND CURRENT inflation rates, analogous to the formulas for permanent income and smoothed utility).
        # However, before we can calculate current inflation (rate of change in goods' price), we need the result of the whole process from the wage bargain until production. Since expected inflation is an input parameter in the wage bargain function, we can use only past values of inflation to form the trend.
        # Furthermore, we can't calculate inflation at t=1 because we need two periods to get the difference in prices. And we can't calculate at t=1 because we still don't have the current price level.
        summation = 0
        for l in range(len(self.pastInflation)): # l = [0,20]
            summation = summation + self.economy.parameters.Ro ** (l) * self.pastInflation[-l-1]

        return (1-self.economy.parameters.Ro)*summation

    def matchFirmAndConsumers(self):
        self.currentPrice = self.economy.firm.getSellingPrice()
        suppliedGoods = self.economy.firm.getProduction()
        households = sorted(self.economy.households, key=lambda hh: hh.getConsumptionDemand(), reverse=True)

        soldGoods = 0
        """ Equation (20) """
        for hh in households:
            if soldGoods >= suppliedGoods:
                hh.effectivelyConsumedGoods = 0
                continue

            soldGoods = soldGoods + hh.getConsumptionDemand()
            hh.effectivelyConsumedGoods = hh.getConsumptionDemand()

            # what about excess demand of the last buying household?
            if soldGoods > suppliedGoods:
                excess = soldGoods - suppliedGoods
                hh.effectivelyConsumedGoods = hh.effectivelyConsumedGoods - excess
                soldGoods = suppliedGoods

        self.aggregateConsumption = soldGoods

    def nextPeriod(self):
        """ Prepare the object for a clean next period """

        self.pastInflation.append(self.getCurrentInflation())
        self.pastInflation = self.pastInflation[-self.economy.parameters.InflationWindowOfObservation:]
            
        self.prevPrice = self.currentPrice
        self.currentPrice = None
