#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct 23 14:55:39 2017

@author: jdimas
"""
import math

class Household:
    
    def __init__(self, householdId, economy):
        self.householdId = householdId
        self.economy = economy
        self.pastIncomes = []
    
    def getReservationWage(self):
        if self.getExpectedInflation() > 0:
            return self.prevWage * (1 + self.getDegreeOfIndexation()*self.getExpectedInflation())
        else:
            return self.prevWage                    
        
    def getDegreeOfIndexation(self):
        # TODO: implement
        return 0.8
    
    def getExpectedInflation(self):
        # TODO: implement
        return 0.02
    
    def getConsumptionDemand(self):
        return self.getConsumptionShare()*self.getPermanentIncome()
        
    def getConsumptionShare(self):
        return self.prevConsumedIncomeShare - self.getConsumptionShareAdjCoeff()*(self.economy.getInterestRate()-self.getExpectedInflation()-self.economy.getNaturalInterestRate())
    
    def getConsumptionShareAdjCoeff(self):
        # TODO: implement
        return 0.8
    
    def getPermanentIncome(self):
        summation = 0
        for l in range(self.economy.currentPeriod+1):
            summation = summation + ro**(self.economy.currentPeriod-l)*self.pastIncomes[l]/self.economy.pastPriceLevels[l]
        
        return (1-ro)*summation
    
    def getCurrentIncome(self):
        return self.getReservationWage()*self.getEffectivelySuppliedLabour() + self.economy.prevTotalProfits/self.economy.getNmbHouseholds() + self.prevSavingsBalance(1+self.economy.prevInterestRate)
    
    def getEffectivelySuppliedLabour(self):
        # TODO: implement
        return 0.8
    
    def getLabourSipply(self):
        return innelasticLabourSupply
    
    def updateSavingsBalance(self, income, consumption, priceLevel):
        self.savingsBalance = income - consumption*priceLevel
        
    def getSmoothedUtility(self):
        summation = 0
        for l in range(self.economy.currentPeriod+1):
            summation = summation + ro**(self.economy.currentPeriod-l)*self.getUtility()
        
        return (1-ro)*summation
    
    def getUtility(self):
        return math.log(self.getConsumption())
        
    def getConsumption(self):
        # TODO: implement
        return 20
        
    
class Economy:
    def __init__(self, initialPriceLevel):
        self.pastPriceLevels = []
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

# Parameters
nmbHouseholds = 10
ro = 0.5 # [0,1[
initialPriceLevel = 1
innelasticLabourSupply = 1

# Simulation
economy = Economy(initialPriceLevel)
households = []
for i in range(nmbHouseholds):
    householdId = i+1
    household = Household(householdId, economy)
    economy.households = economy.append(household)
    households.append(household)