#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Oct 24 16:47:09 2017

@author: jdimas
"""

from model.parameters import Parameters

class Firm:
    
    def __init__(self, economy):
        self.economy = economy
        self.pastProfits = [0]
        self.pastPrices = [0]
    
    def getProduction(self):
        return Parameters.TechnologyFactor*sum([hh.getEffectivelySuppliedLabour() for hh in self.economy.households])**(1-Parameters.Alpha)
    
    def getTotalCost(self):
        return sum([hh.getWage() * hh.getEffectivelySuppliedLabour() for hh in self.economy.households])
    
    def getMarginalCost(self):
        return self.getTotalCost()/((1-Parameters.Alpha)*self.getProduction())
    
    def getPrice(self):
        return (1+Parameters.Markup)*self.getTotalCost()/((1-Parameters.Alpha)*self.getProduction())
    
    def getProfit(self):
        return self.getPrice()*self.economy.getEquilibriumGoodsQuantity() - self.getTotalCost()
    
    def getPrevProfitTrend(self):
        # Explain in the paper: the original paper defines the labour demand in t+1. To get it in t, we had to shift back one period. 
        summation = 0
        for l in range(self.economy.currentPeriod):
            summation = summation + Parameters.Ro**(self.economy.currentPeriod-1-l)*self.pastProfits[l-1]/self.economy.pastPriceLevels[l-1]
        
        return (1-Parameters.Ro)*summation
    
    def getPrevProfit(self):
        return self.pastProfits[self.economy.currentPeriod-2]
    
    def getPrevPrice(self):
        return self.pastPrices[self.economy.currentPeriod-2]
    
    def getLabourDemand(self):
        profitTrend = self.getProfitTrend()
        prevTotalLabour = sum([hh.getPrevEffectivelySuppliedLabour() for hh in self.economy.households])
        if self.getPrevProfit()/self.getPrices() >= profitTrend:
            return prevTotalLabour * (1+Parameters.Epsilon)
        else:
            return prevTotalLabour * (1-Parameters.Epsilon)