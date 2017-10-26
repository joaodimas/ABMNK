#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Oct 24 19:04:00 2017

@author: João Dimas and Umberto Collodel
"""
from model.parameters import Parameters

class GoodsMarket:
    
    def __init__(self, economy):
        self.economy = economy
        self.pastPrices = []
            
    def getPrevPrice(self):
        return self.pastPrices[self.economy.currentPeriod-2]
    
    def getCurrentPrice(self):
        return self.economy.firm.getSellingPrice()
    
    def getCurrentInflation(self):
        currentPrice = self.getCurrentPrice()
        prevPrice = self.getPrevPrice()
        return (currentPrice-prevPrice)/prevPrice
    
    def getPastInflationTrend(self):
        # We believe there's a mistake in the paper, equation 17. According to the paper, for workers to form their expected inflation, they need the inflation trend at time t (using all PAST AND CURRENT inflation rates, analogous to the formulas for permanent income and smoothed utility). 
        # However, before we can calculate current inflation (rate of change in goods' price), we need the result of the whole process from the wage bargain until production. Since expected inflation is an input parameter in the wage bargain function, we can use only past values of inflation to form the trend.
        summation = 0
        for l in range(1, self.economy.currentPeriod): # We can't calculate inflation at t=0 because we need two periods to get the difference in prices.
            pastInflation = (self.pastPrices[l]-self.pastPrices[l-1])/self.pastPrices[l-1]
            summation = summation + Parameters.Ro**(self.economy.currentPeriod-1+l)*pastInflation
        
        return (1-Parameters.Ro)*summation
    
    def matchFirmAndWorkers(self):
        suppliedGoods = self.economy.firm.getProduction()
        households = sorted(self.economy.households, key=lambda hh: hh.getConsumptionDemand())
        
        soldGoods = 0
        """ Equation (20) """
        for hh in households:
            if soldGoods >= suppliedGoods:
                hh.effectivelyConsumedGoods = 0
                continue
            
            soldGoods = soldGoods + hh.getConsumptionDemand()/self.getCurrentPrice()
            hh.effectivelyConsumedGoods = hh.getConsumptionDemand()
            
            # what about excess demand of the last buying household?
            if soldGoods > suppliedGoods:
                excess = soldGoods - suppliedGoods
                hh.effectivelyConsumedGoods = hh.effectivelyConsumedGoods - excess
                soldGoods = suppliedGoods
    
    def nextPeriod(self):
        """ Prepare the object for a clean next period """
        self.pastPrices.append(self.getCurrentPrice())