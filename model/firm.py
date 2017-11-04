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

class Firm:
    
    def __init__(self, economy):
        self.economy = economy
        self.pastProfits = []
        self.pastHiredLabour = []
        self.pastSoldGoods = []
        self.sellingPrice = None
        self.totalCost = None
    
    def getProduction(self):
        """ Equation (9) """
        return Parameters.TechnologyFactor*self.economy.labourMarket.aggregateHiredLabour**(1-Parameters.Alpha)
    
    def getTotalCost(self):
        """ Equation (10) """
        if self.totalCost is None:
            self.totalCost = sum([hh.getReservationWage() * hh.effectivelySuppliedLabour for hh in self.economy.households])
            
        return self.totalCost
    
    def getMarginalCost(self):
        """ Equation (11) """
        return self.getTotalCost()/((1-Parameters.Alpha)*self.getProduction())
    
    def getSellingPrice(self):
        """ Equation (12) """
        if self.sellingPrice is None:
            self.sellingPrice = (1+Parameters.Mu)*self.getTotalCost()/((1-Parameters.Alpha)*self.getProduction())
            
        #Logger.trace("[Firm] getSellingPrice(): {:.4f}", self.sellingPrice, economy=self.economy)
        return self.sellingPrice
    
    def getProfit(self):
        """ Equation (13) """
        return self.economy.goodsMarket.currentPrice*self.economy.goodsMarket.aggregateSoldGoods - self.getTotalCost()
            
    def getPastProfitTrend(self):
        # TODO: The original paper defines the labour demand in t+1. To get it in t, we had to shift back one period. 
        #Logger.trace("[Firm] Calculating past profit trend.", economy=self.economy)
        summation = 0
        for l in range(self.economy.currentPeriod):
            #Logger.trace("[Firm] Summing past profit of period {:d}.", l, economy=self.economy)
            summation = summation + Parameters.Ro**(self.economy.currentPeriod-1-l)*self.pastProfits[l]/self.economy.goodsMarket.pastPrices[l]
        
        pastProfitTrend = (1-Parameters.Ro)*summation
        #Logger.trace("[Firm] Past profit trend is {:.2f}.", pastProfitTrend, economy=self.economy)
        return pastProfitTrend
    
    def getLabourDemand(self):
        
        if self.economy.currentPeriod == 0: # TODO: See comment on Parameters class. This was not explicit in the paper, therefore we assumed.
            return Parameters.InitialLabourDemand
        
        """ Equation (14) and (15) """

        prevHiredLabour = self.pastHiredLabour[-1]
        if self.pastProfits[-1]/self.economy.goodsMarket.pastPrices[-1] >= self.getPastProfitTrend():
            return prevHiredLabour * (1+Parameters.Epsilon)
        else:
            return prevHiredLabour * (1-Parameters.Epsilon)
        
    def nextPeriod(self):
        """ Prepare the object for a clean next period """
        self.pastProfits.append(self.getProfit())
        self.pastHiredLabour.append(self.economy.labourMarket.aggregateHiredLabour)
        self.pastSoldGoods.append(self.economy.goodsMarket.aggregateSoldGoods)
        self.sellingPrice = None
        self.totalCost = None
        
        assert len(self.pastProfits) == self.economy.currentPeriod+1
        assert len(self.pastHiredLabour) == self.economy.currentPeriod+1
        assert len(self.pastSoldGoods) == self.economy.currentPeriod+1        