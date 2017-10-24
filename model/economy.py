#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Oct 24 16:42:34 2017

@author: jdimas
"""

class Economy:
    def __init__(self, initialPriceLevel):
        self.pastPriceLevels = [0.1]
        self.priceLevel = initialPriceLevel
        self.currentPeriod = 1
        self.prevTotalProfits = 0
        self.prevInterestRate = 0
        self.households = []
        
    def getNmbHouseholds(self):
        return len(self.households)
    
    def getNaturalInterestRate(self):
        #TODO: implement
        return 0.03
    
    def getInterestRate(self):
        #TODO: implement
        return 0.03
