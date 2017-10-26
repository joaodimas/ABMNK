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
        self.pastIncomes = []
        self.pastEffectivelySuppliedLabour = []
        self.pastUtilities = []
        self.effectivelySuppliedLabour = None
        self.effectivelyConsumedGoods = None

        # TODO: put real values
        self.indexationStrategy = 0.5
        self.substitutionStrategy = 0.5
        self.prevConsumptionShare = 0
        self.prevSavingsBalance = 0
    
    def getReservationWage(self):
        """ Equation (1) """
        if self.getExpectedInflation() > 0:
            return self.prevWage * (1 + self.indexationStrategy*self.getExpectedInflation())
        else:
            return self.prevWage                   
    
    def getExpectedInflation(self):
        """ Equation (17) """
        return Parameters.Chi*self.getPerceivedInflationTarget()+(1-Parameters.Chi)*self.economy.goodsMarket.getPastInflationTrend()
    
    def getPerceivedInflationTarget(self):
        if Parameters.AllHouseholdsSameExpectation:
            if self.economy.homogeneousNoiseInflationTarget is None:
                self.economy.homogeneousNoiseInflationTarget = random.gauss(0,Parameters.NoiseInflationTargetPerceptionSD)
            return Parameters.InflationTarget + self.economy.homogeneousNoiseInflationTarget
            
        return Parameters.InflationTarget + random.gauss(0,Parameters.NoiseInflationTargetPerceptionSD)
    
    def getConsumptionDemand(self):
        """ Equation (2) """
        return self.getConsumptionShare()*self.getPermanentIncome()
        
    def getConsumptionShare(self):
        """ Equation (6) """
        return self.prevConsumptionShare - self.substitutionStrategy*(self.economy.centralBank.getInterestRate()-self.getExpectedInflation()-Parameters.NaturalInterestRate)
    
    def getPermanentIncome(self):
        """ Equation (3) """
        summation = 0
        for l in range(self.economy.currentPeriod):
            summation = summation + Parameters.Ro**(self.economy.currentPeriod-l)*self.pastIncomes[l]/self.economy.goodsMarket.pastPrices[l]
        summation = summation + self.getCurrentIncome()/self.economy.goodsMarket.getCurrentPrice()
        return (1-Parameters.Ro)*summation
    
    def getCurrentIncome(self):
        """ Equation (4) """
        return self.getReservationWage()*self.effectivelySuppliedLabour + self.economy.firm.getPrevProfit()/self.economy.getNumberOfHouseholds() + self.prevSavingsBalance(1+self.economy.centralBank.prevInterestRate)
    
    def getLabourSupply(self):
        return Parameters.InnelasticLabourSupply
    
    def getSavingsBalance(self, income, consumption, priceLevel):
        """ Equation (5) """
        return income - consumption*priceLevel
        
    def getSmoothedUtility(self):
        """ Equation (7) """
        summation = 0
        for l in range(self.economy.currentPeriod):
            summation = summation + Parameters.Ro**(self.economy.currentPeriod-l)*self.pastUtilities[l]
        summation = summation + self.getUtility()
        return (1-Parameters.Ro)*summation
    
    def getUtility(self):
        return math.log(self.effectivelyConsumedGoods)
    
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
            """ Equation (8) """
            hh['probability'] = hh['smoothedUtility']/sumOfUtility
            
        pointInCDF = random.randint(0,1)
        sumOfProbabilities = 0
        for hh in households:
            sumOfProbabilities = sumOfProbabilities + hh['probability']
            if sumOfProbabilities > pointInCDF:
                return hh['household']

    def getPrevEffectivelySuppliedLabour(self):
        return self.pastEffectivelySuppliedLabour[self.economy.currentPeriod-2]
    
    def nextPeriod(self):
        """ Prepare the object for a clean next period """
        self.pastEffectivelySuppliedLabour.append(self.effectivelySuppliedLabour)
        self.pastIncomes.append(self.getCurrentIncome())
        self.pastUtilities.append(self.getUtility())
        self.prevConsumptionShare = self.getConsumptionShare()
        self.prevSavingsBalance = self.getSavingsBalance()
        self.effectivelySuppliedLabour = None
        self.effectivelyConsumedGoods = None
        
        