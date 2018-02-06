#!/usr/bin/env python3
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

class Firm:

    def __init__(self, economy):
        self.economy = economy
        self.pastProfits = []
        self.pastHiredLabour = []
        self.pastSoldGoods = []
        self.sellingPrice = None
        self.totalCost = None
        self.profit = None
        self.production = None
        self.labourDemand = Parameters.InitialLabourDemand

    def getProduction(self):
        """ Equation (9) """
        if self.production is None:
            self.production = Parameters.TechnologyFactor * self.economy.labourMarket.aggregateHiredLabour ** (1 - Parameters.Alpha)

        return self.production

    def getTotalCost(self):
        """ Equation (10), wage bill """
        if self.totalCost is None:
            self.totalCost = sum([hh.getReservationWage() * hh.effectivelySuppliedLabour for hh in self.economy.households])

        return self.totalCost

    def getMarginalCost(self):
        """ Equation (11) """
        return self.getTotalCost()/((1-Parameters.Alpha)*self.getProduction())

    def getSellingPrice(self):
        """ Equation (12) """
        if self.sellingPrice is None:
            self.sellingPrice = (1 + Parameters.Mu) * self.getTotalCost() / ((1 - Parameters.Alpha) * self.getProduction())

        if self.sellingPrice > Parameters.MaximumPricePrecision:
            raise ValueError("Price is above Python's mathematical precision. Aborting simulation.")

        return self.sellingPrice

    def getProfitRate(self):
        return self.getProfit() / self.getTotalCost()

    def getProfit(self):
        """ Equation (13) """
        if self.profit is None:
            self.profit = self.economy.goodsMarket.currentPrice*self.economy.goodsMarket.aggregateSoldGoods - self.getTotalCost()

        return self.profit

    def getProfitTrend(self):
        summation = 0
        if self.economy.currentPeriod <= Parameters.FirmWindowOfObservation:
            firstObservation = 0
        else:
            firstObservation = self.economy.currentPeriod - Parameters.FirmWindowOfObservation
            
        for l in range(firstObservation, self.economy.currentPeriod-1):
            summation = summation + Parameters.Ro ** (self.economy.currentPeriod - 1 - l) * self.pastProfits[l] / self.economy.goodsMarket.pastPrices[l]

        summation = summation + self.getProfit() / self.economy.goodsMarket.currentPrice
        return (1 - Parameters.Ro) * summation

    def chooseNextPeriodLabourDemand(self):
        if self.getProfit()/self.economy.goodsMarket.currentPrice >= self.getProfitTrend():
            self.labourDemand = self.labourDemand * (1 + Parameters.Epsilon)
        else:
            self.labourDemand = self.labourDemand * (1 - Parameters.Epsilon)

    def nextPeriod(self):
        """ Prepare the object for a clean next period """
        self.pastProfits.append(self.getProfit())
        self.pastHiredLabour.append(self.economy.labourMarket.aggregateHiredLabour)
        self.pastSoldGoods.append(self.economy.goodsMarket.aggregateSoldGoods)
        self.chooseNextPeriodLabourDemand()
        self.sellingPrice = None
        self.totalCost = None
        self.profit = None
        self.production = None

        assert len(self.pastProfits) == self.economy.currentPeriod
        assert len(self.pastHiredLabour) == self.economy.currentPeriod
        assert len(self.pastSoldGoods) == self.economy.currentPeriod