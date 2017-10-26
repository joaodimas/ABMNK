#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Oct 24 16:42:34 2017

@author: João Dimas and Umberto Collodel
"""

from model.labourmarket import LabourMarket
from model.goodsmarket import GoodsMarket
from model.centralbank import CentralBank
from model.firm import Firm
from model.household import Household
from model.parameters import Parameters

class Economy:
    def __init__(self, simulationNumber):
        self.simulationNumber = simulationNumber
        self.currentPeriod = 1        
        self.households = []
        for i in range(Parameters.NumberOfHouseholds):
            householdId = i+1
            household = Household(householdId, self)
            self.households.append(household)
        self.priceLevel = Parameters.InitialPriceLevel
        self.centralBank = CentralBank(self)
        self.labourMarket = LabourMarket(self)
        self.goodsMarket = GoodsMarket(self)
        self.firm = Firm(self)
        
        # Only used if Parameters.AllHouseholdsSameExpectation == True
        self.homogeneousNoiseInflationTarget = None
        
    def getNumberOfHouseholds(self):
        return len(self.households)
    
    def runCurrentPeriod(self):
        self.labourMarket.matchFirmAndWorkers()
        self.goodsMarket.matchFirmAndWorkers()

    def nextPeriod(self):
        """ Prepare the object for a clean next period """
        for hh in self.households:
            hh.nextPeriod()
        
        self.firm.nextPeriod()
        self.goodsMarket.nextPeriod()
        self.labourMarket.nextPeriods()
        self.currentPeriod = self.currentPeriod + 1
        self.homogeneousNoiseInflationTarget = None