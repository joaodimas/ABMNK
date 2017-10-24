#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct 23 14:55:39 2017

@author: João Dimas and Umberto Collodel
"""
import math
import random
import statistics
from model.parameters import Parameters

class Household:
    
    def __init__(self, householdId, economy):
        self.householdId = householdId
        self.economy = economy
        self.pastIncomes = [0]
        self.pastEffectivelySuppliedLabour = [0]
        self.pastUtilities = [0]
        
        # TODO: put real values
        self.indexationStrategy = 0.5
        self.substitutionStrategy = 0.5
        self.prevConsumptionShare = 0
    
    def getWage(self):
        if self.getExpectedInflation() > 0:
            return self.prevWage * (1 + self.indexationStrategy*self.getExpectedInflation())
        else:
            return self.prevWage                   
    
    def getExpectedInflation(self):
        # TODO: implement
        return 0.02
    
    def getConsumptionDemand(self):
        return self.getConsumptionShare()*self.getPermanentIncome()
        
    def getConsumptionShare(self):
        return self.prevConsumptionShare - self.substitutionStrategy*(self.economy.getInterestRate()-self.getExpectedInflation()-self.economy.getNaturalInterestRate())
    
    def getPermanentIncome(self):
        summation = 0
        for l in range(self.economy.currentPeriod+1):
            summation = summation + Parameters.Ro**(self.economy.currentPeriod-l)*self.pastIncomes[l-1]/self.economy.pastPriceLevels[l-1]
        
        return (1-Parameters.Ro)*summation
    
    def getCurrentIncome(self):
        return self.getWage()*self.getEffectivelySuppliedLabour() + self.economy.prevTotalProfits/self.economy.getNmbHouseholds() + self.prevSavingsBalance(1+self.economy.prevInterestRate)
    
    def getEffectivelySuppliedLabour(self):
        # TODO: implement
        return 0.8
    
    def getLabourSipply(self):
        return Parameters.InnelasticLabourSupply
    
    def updateSavingsBalance(self, income, consumption, priceLevel):
        self.savingsBalance = income - consumption*priceLevel
        
    def getSmoothedUtility(self):
        summation = 0
        for l in range(self.economy.currentPeriod+1):
            summation = summation + Parameters.Ro**(self.economy.currentPeriod-l)*self.pastUtilities[l-1]
        
        return (1-Parameters.Ro)*summation
    
    def getUtility(self):
        return math.log(self.getConsumption())
        
    def getConsumption(self):
        # TODO: implement
        return 20
    
    def imitateSomeone(self):
        other = self.selectHouseholdToImitate()
        self.indexationStrategy = other.indexationStrategy
        self.substitutionStrategy = other.substitutionStrategy
        
    def experimentNewStrategy(self):
        meanIndexationStrategy = statistics.mean([hh.indexationStrategy for hh in self.economy.households])
        newIndexationStrategy = random.gauss(meanIndexationStrategy, Parameters.IndexationStrategySD)    
        if newIndexationStrategy < 0:
            newIndexationStrategy = 0
        
        meanSubstitutionStrategy = statistics.mean([hh.substitutionStrategy for hh in self.economy.households])
        newSubstitutionStrategy = random.gauss(meanSubstitutionStrategy, Parameters.SubstitutionStrategySD)
    
        self.indexationStrategy = newIndexationStrategy
        self.substitutionStrategy = newSubstitutionStrategy
        
    def selectHouseholdToImitate(self):
        # Since the original paper is not explicit about this, we assume the following:
        # (i) Only the other households enter the selection function.
        # (ii) Households look at the values of utility in previous period, instead of current.
        otherHouseholds = [hh for hh in self.economy.households if hh.householdId != self.householdId]
        households = []
        sumOfUtility = 0
        for hh in otherHouseholds:
            households.append({'household': hh, 'smoothedUtility': math.exp(hh.getSmoothedUtility())})
            sumOfUtility = sumOfUtility + math.exp(hh.getSmoothedUtility())
        
        for hh in households:
            hh['probability'] = hh['smoothedUtility']/sumOfUtility
            
        pointInCDF = random.randint(0,1)
        sumOfProbabilities = 0
        for hh in households:
            sumOfProbabilities = sumOfProbabilities + hh['probability']
            if sumOfProbabilities > pointInCDF:
                return hh['household']

    def getPrevEffectivelySuppliedLabour(self):
        return self.pastEffectivelySuppliedLabour[self.economy.currentPeriod-2]