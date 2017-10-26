#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Oct 24 16:47:09 2017

@author: João Dimas and Umberto Collodel
"""

from model.parameters import Parameters

class Firm:
    
    def __init__(self, economy):
        self.economy = economy
        self.pastProfits = []
        self.pastHiredLabour = []
        self.pastSoldGoods = []
    
    def getProduction(self):
        """ Equation (9) """
        return Parameters.TechnologyFactor*self.getEffectivelyHiredLabour()**(1-Parameters.Alpha)
    
    def getTotalCost(self):
        """ Equation (10) """
        return sum([hh.getReservationWage() * hh.getEffectivelySuppliedLabour() for hh in self.economy.households])
    
    def getMarginalCost(self):
        """ Equation (11) """
        return self.getTotalCost()/((1-Parameters.Alpha)*self.getProduction())
    
    def getSellingPrice(self):
        """ Equation (12) """
        return (1+Parameters.Markup)*self.getTotalCost()/((1-Parameters.Alpha)*self.getProduction())
    
    def getProfit(self):
        """ Equation (13) """
        return self.getSellingPrice()*self.getEffectivelySoldGoods() - self.getTotalCost()
    
    def getEffectivelyHiredLabour(self):
        return sum([hh.getEffectivelySuppliedLabour() for hh in self.economy.households])
        
    def getEffectivelySoldGoods(self):
        return sum([hh.effectivelyConsumedGoods for hh in self.economy.households])
    
    def getPastProfitTrend(self):
        # The original paper defines the labour demand in t+1. To get it in t, we had to shift back one period. 
        summation = 0
        for l in range(self.economy.currentPeriod):
            summation = summation + Parameters.Ro**(self.economy.currentPeriod-1-l)*self.pastProfits[l]/self.economy.goodsMarket.pastPrices[l]
        return (1-Parameters.Ro)*summation
    
    def getPrevProfit(self):
        return self.pastProfits[self.economy.currentPeriod-2]
    
    def getLabourDemand(self):
        """ Equation (14) and (15) """

        prevHiredLabour = sum([hh.getPrevEffectivelySuppliedLabour() for hh in self.economy.households])
        if self.getPrevProfit()/self.getSellingPrice() >= self.getPastProfitTrend():
            return prevHiredLabour * (1+Parameters.Epsilon)
        else:
            return prevHiredLabour * (1-Parameters.Epsilon)
        
    def nextPeriod(self):
        """ Prepare the object for a clean next period """
        self.pastProfits.append(self.getProfit())
        self.pastHiredLabour.append(self.getEffectivelyHiredLabour())
        self.pastSoldGoods.append(self.getEffectivelySoldGoods())