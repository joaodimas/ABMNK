#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Project for course Quantitative Methods in Finance, Prof. Eric Vansteenberghe.
Université Paris 1 Panthéon-Sorbonne
Program: Master 2 Financial Economics, 2017.
Authors: João Dimas (joaohenriqueavila@gmail.com) and Umberto Collodel (umberto.collodel@gmail.com)

Replication of an agent-based model described in:
Salle, I., Yıldızoğlu, M., & Sénégas, M.-A. (2013). Inflation targeting in a learning economy: An ABM perspective. Economic Modelling, 34, 114–128.
"""

from model.parameters import Parameters
from model.util.logger import Logger
from model.util.math import Math

class Firm:
    
    def __init__(self, economy):
        self.economy = economy
        self.pastProfits = []
        self.pastHiredLabour = []
        self.pastSoldGoods = []
        self.sellingPrice = None
        self.totalCost = None
        self.profit = None
        self.labourDemand = Parameters.InitialLabourDemand
    
    def getProduction(self):
        """ Equation (9) """
        return Parameters.TechnologyFactor * self.economy.labourMarket.aggregateHiredLabour ** (1 - Parameters.Alpha)
    
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
            
        #Logger.trace("[Firm] getSellingPrice(): {:.4f}", self.sellingPrice, economy=self.economy)
        return self.sellingPrice
    
    def getProfitRate(self):
        return self.getProfit() / self.getTotalCost()
    
    def getProfit(self):
        """ Equation (13) """
        if self.profit is None:
            self.profit = self.economy.goodsMarket.currentPrice*self.economy.goodsMarket.aggregateSoldGoods - self.getTotalCost()
        
        if self.economy.goodsMarket.aggregateSoldGoods == self.getProduction():
            theoreticalProfitRate = (Parameters.Mu + Parameters.Alpha)/(1 + Parameters.Mu) * Parameters.TechnologyFactor * self.economy.labourMarket.aggregateHiredLabour ** (1 - Parameters.Alpha)
            assert Math.isEquivalent(theoreticalProfitRate, self.getProfitRate()), "We sold all production but profit rate is different from expected theoretically. theoreticalProfitRate: {:.2f}, profitRate: {:.2f}".format(theoreticalProfitRate, self.getProfitRate())
        return self.profit
            
    def getProfitTrend(self):
        summation = 0
        for l in range(self.economy.currentPeriod):
            summation = summation + Parameters.Ro ** (self.economy.currentPeriod - l) * self.pastProfits[l] / self.economy.goodsMarket.pastPrices[l]
            
        summation = summation + self.getProfit() / self.economy.goodsMarket.currentPrice        
        return (1 - Parameters.Ro) * summation
    
    def chooseNextPeriodLabourDemand(self):
        if self.getProfit()/self.goodsMarket.currentPrice >= self.getProfitTrend():
            self.labourDemand = self.labourDemand * (1 + Parameters.Epsilon)
        else:
            self.labourDemand = self.labourDemand * (1 - Parameters.Epsilon)
        
    def nextPeriod(self):
        """ Prepare the object for a clean next period """
        self.pastProfits.append(self.getProfit())
        self.pastHiredLabour.append(self.economy.labourMarket.aggregateHiredLabour)
        self.pastSoldGoods.append(self.economy.goodsMarket.aggregateSoldGoods)
        self.sellingPrice = None
        self.totalCost = None
        self.labourDemand = None
        self.profit = None
        self.chooseNextPeriodLabourDemand()
        
        assert len(self.pastProfits) == self.economy.currentPeriod+1
        assert len(self.pastHiredLabour) == self.economy.currentPeriod+1
        assert len(self.pastSoldGoods) == self.economy.currentPeriod+1        