#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Oct 24 19:04:00 2017

@author: jdimas
"""

class GoodsMarket:
    
    def __init__(self, economy):
        self.economy = economy
        
    def getEquilibriumGoodsQuantity(self):
        # TODO: verify
        return min(self.economy.firm.getProduction(), sum([hh.getConsumptionDemand() for hh in self.economy.households]))