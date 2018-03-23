#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""

Code for my master thesis.

Still under development.

@author: João Dimas (joaohenriqueavila@gmail.com)

"""

class Firm:

    def __init__(self, economy):
        self.economy = economy
        self.pastRealProfits = []
        self.pastHiredLabour = []
        self.pastSoldGoods = []
        self.sellingPrice = None
        self.totalCost = None
        self.profit = None
        self.production = None
        self.labourDemand = self.economy.parameters.InitialLabourDemand
        self.profitTrend = None

    def getProduction(self):
        """ Equation (9) """
        if self.production is None:
            self.production = self.productionFunction(self.economy.labourMarket.aggregateHiredLabour)

        return self.production
    
    def productionFunction(self, labour):
        return self.economy.parameters.TechnologyFactor * labour ** (1 - self.economy.parameters.Alpha)

    def getTotalCost(self):
        """ Equation (10), wage bill """
        if self.totalCost is None:
            self.totalCost = sum([hh.getReservationWage() * hh.effectivelySuppliedLabour for hh in self.economy.households])

        return self.totalCost

    def getMarginalCost(self):
        """ Equation (11) """
        return self.getTotalCost()/((1-self.economy.parameters.Alpha)*self.getProduction())

    def getSellingPrice(self):
        """ Equation (12) """
        if self.sellingPrice is None:
            self.sellingPrice = (1 + self.economy.parameters.Mu) * self.getTotalCost() / ((1 - self.economy.parameters.Alpha) * self.getProduction())

        if self.sellingPrice > self.economy.parameters.MaximumPrecision:
            raise ValueError("Price is above Python's mathematical precision. Aborting simulation.")

        return self.sellingPrice

    def getCurrentProfit(self):
        """ Equation (13) """
        if self.profit is None:
            self.profit = self.economy.goodsMarket.currentPrice*self.economy.goodsMarket.aggregateConsumption - self.getTotalCost()

        return self.profit

    def getProfitTrend(self):
        if self.profitTrend is None:
            summation = self.getCurrentRealProfit()
            for l in range(1, len(self.pastRealProfits)+1): # l = [1,20]
                summation = summation + self.economy.parameters.Ro ** l * self.pastRealProfits[-l]
                assert l != 20 or self.pastRealProfits[-l] == self.pastRealProfits[0]
            self.profitTrend = (1-self.economy.parameters.Ro)*summation
        return self.profitTrend

    def chooseNextPeriodLabourDemand(self):
        if self.getCurrentRealProfit() >= self.getProfitTrend():
            self.labourDemand = self.labourDemand * (1 + self.economy.parameters.Epsilon)
        else:
            self.labourDemand = self.labourDemand * (1 - self.economy.parameters.Epsilon)

    def getCurrentRealProfit(self):
        return self.getCurrentProfit() / self.getSellingPrice()
    
    def getPrevProfitPerShare(self):
        return self.prevProfit / len(self.economy.households) if self.economy.currentPeriod > 1 else 0

    def nextPeriod(self):
        """ Prepare the object for a clean next period """
        self.prevProfit = self.getCurrentProfit()
        self.pastRealProfits.append(self.getCurrentRealProfit())
        self.pastRealProfits = self.pastRealProfits[-self.economy.parameters.ProfitWindowOfObservation:]
        assert self.economy.currentPeriod <= self.economy.parameters.ProfitWindowOfObservation or len(self.pastRealProfits) == self.economy.parameters.ProfitWindowOfObservation
        
        self.pastHiredLabour.append(self.economy.labourMarket.aggregateHiredLabour)
        self.pastSoldGoods.append(self.economy.goodsMarket.aggregateConsumption)
        self.chooseNextPeriodLabourDemand()
        self.sellingPrice = None
        self.totalCost = None
        self.profit = None
        self.production = None
        self.profitTrend = None

    