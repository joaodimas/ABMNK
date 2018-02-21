#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""

Code for my master thesis.

Still under development.

@author: João Dimas (joaohenriqueavila@gmail.com)

"""

from model.labourmarket import LabourMarket
from model.goodsmarket import GoodsMarket
from model.centralbank import CentralBank
from model.firm import Firm
from model.household import Household
from model.parameters import Parameters
from model.util.logger import Logger
import random, statistics, sys

class Economy:
    def __init__(self, simulationNumber):
        #Logger.trace("Initializing Economy")
        self.simulationNumber = simulationNumber
        self.prevInterestRate = 0
        self.outputGap = None
        self.meanExpectedInflation = None
        self.meanRealSavingsBalance = None
        self.meanIndexationStrategy = None 
        self.meanSubstitutionStrategy = None
        self.stdevExpectedInflation = None
        self.stdevRealSavingsBalance = None
        self.stdevIndexationStrategy = None
        self.stdevSubstitutionStrategy = None

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

        # We are assuming that initially all households choose random strategies based on initial mean values set in Parameters.
        #Logger.trace("Households are mutating randomly to define their initial strategies")
        if Parameters.ProbMutation > 0:
            for hh in self.households:
                hh.mutateRandomly()

        # Only used if Parameters.AllHouseholdsSameExpectation == True
        self.homogeneousNoiseInflationTarget = None

    def runCurrentPeriod(self):
        self.centralBank.setNominalInterestRate()
        self.labourMarket.matchFirmAndWorkers()
        self.goodsMarket.matchFirmAndConsumers()

        # We store the current strategies in different variables because households imitate the behaviour of past period. This will be used in the learn() function.
        for hh in self.households:
            hh.prevIndexationStrategy = hh.indexationStrategy
            hh.prevSubstitutionStrategy = hh.substitutionStrategy

        #Logger.trace("[Learning] Households are learning.", economy=self)
        if Parameters.LearningLevel is not None:
            for hh in self.households:
                hh.learn() # Mutate or imitate

    def getOutputGap(self):
        if self.outputGap is None:
            potentialOutput = self.firm.productionFunction(self.labourMarket.getTotalLabourSupply())
            currentOutput = self.firm.getProduction()
            self.outputGap = currentOutput / potentialOutput - 1
            
        return self.outputGap

    def nextPeriod(self):
        """ Prepare the object for a clean next period """
        for hh in self.households:
            hh.nextPeriod()

        self.firm.nextPeriod()
        self.goodsMarket.nextPeriod()
        self.labourMarket.nextPeriod()
        self.currentPeriod = self.currentPeriod + 1
        self.homogeneousNoiseInflationTarget = None
        self.prevInterestRate = self.nominalInterestRate

        self.outputGap = None
        self.meanExpectedInflation = None
        self.meanRealSavingsBalance = None
        self.meanIndexationStrategy = None 
        self.meanSubstitutionStrategy = None
        self.stdevExpectedInflation = None
        self.stdevRealSavingsBalance = None
        self.stdevIndexationStrategy = None
        self.stdevSubstitutionStrategy = None
        
    def getHomogeneousNoiseInflationTarget(self):
        if self.homogeneousNoiseInflationTarget is None:
            self.homogeneousNoiseInflationTarget = random.gauss(0,Parameters.NoiseInflationTargetPerceptionSD)

        return self.homogeneousNoiseInflationTarget
    
    def getMeanExpectedInflation(self):
        if self.meanExpectedInflation is None:
            self.meanExpectedInflation = statistics.mean([hh.getExpectedInflation() for hh in self.households])
            
        return self.meanExpectedInflation
    
    def getMeanRealSavingsBalance(self):
        if self.meanRealSavingsBalance is None:
            self.meanRealSavingsBalance = statistics.mean([hh.getSavingsBalance()/self.goodsMarket.currentPrice for hh in self.households])
            
        return self.meanRealSavingsBalance
    
    def getMeanIndexationStrategy(self):
        if self.meanIndexationStrategy is None:
            self.meanIndexationStrategy = statistics.mean([hh.indexationStrategy for hh in self.households])
            
        return self.meanIndexationStrategy
    
    def getMeanSubstitutionStrategy(self):
        if self.meanSubstitutionStrategy is None:
            self.meanSubstitutionStrategy = statistics.mean([hh.substitutionStrategy for hh in self.households])
            
        return self.meanSubstitutionStrategy
    
    def getStDevExpectedInflation(self):
        if self.stdevExpectedInflation is None:
            self.stdevExpectedInflation = statistics.stdev([hh.getExpectedInflation() for hh in self.households])
            
        return self.stdevExpectedInflation

    def getStDevRealSavingsBalance(self):
        if self.stdevRealSavingsBalance is None:
            self.stdevRealSavingsBalance = statistics.stdev([hh.getSavingsBalance()/self.goodsMarket.currentPrice for hh in self.households])
            
        return self.stdevRealSavingsBalance

    def getStDevIndexationStrategy(self):
        if self.stdevIndexationStrategy is None:
            self.stdevIndexationStrategy = statistics.stdev([hh.indexationStrategy for hh in self.households])
            
        return self.stdevIndexationStrategy
    
    def getStDevSubstitutionStrategy(self):
        if self.stdevSubstitutionStrategy is None:
            self.stdevSubstitutionStrategy = statistics.stdev([hh.substitutionStrategy for hh in self.households])
            
        return self.stdevSubstitutionStrategy
    
    def describeCurrentPeriod(self):
        if self.currentPeriod % 10 == 0:
            message = """ 
                PERIOD {:d}
                ----------------------------
                Unemployment rate: {:.2%}
                Inflation: {:.2%}
                Interest rate (nominal): {:.2%}
                
                Production: {:.2f}
                Goods sold: {:.2f}
                Excess supply: {:.2f}
                Price: {:.2f}
                
                Mean expected inflation: {:.2%}
                Real interest rate: {:.2%}
                Output gap: {:.2%}
                
                Total profit (real): {:.2f}
                Profit trend (real): {:.2f}
                Wage rate (real): {:.2f}
                
                Mean perm. income (real): {:.2f}
                Mean current income (real): {:.2f}
                Mean savings (real): {:.2f}
                Mean index. strat: {:.2f}
                Mean subs. strat: {:.2f}
                Mean cons. share: {:.2f}
                Mean cons. demand: {:.2f}
    
                Std dev expected inflation: {:.2f}
                Std dev index. strat: {:.2f}
                Std dev subs. strat: {:.2f}
                ----------------------------
            """.format(
                    self.currentPeriod,
                    
                    self.labourMarket.getUnemploymentRate(),
                    self.goodsMarket.getCurrentInflation(),
                    self.nominalInterestRate,
                    
                    self.firm.getProduction(),
                    self.goodsMarket.aggregateConsumption,
                    self.firm.getProduction()-self.goodsMarket.aggregateConsumption,
                    self.goodsMarket.currentPrice,
                    
                    self.getMeanExpectedInflation(),
                    self.nominalInterestRate - self.getMeanExpectedInflation(),
                    self.getOutputGap(),
                    
                    self.firm.getCurrentRealProfit(),
                    self.firm.getProfitTrend(),
                    self.labourMarket.getRealWageRate(),
                    
                    statistics.mean([hh.getPermanentIncome() for hh in self.households]),
                    statistics.mean([hh.getCurrentNominalIncome()/self.goodsMarket.currentPrice for hh in self.households]),
                    self.getMeanRealSavingsBalance(),
                    self.getMeanIndexationStrategy(),
                    self.getMeanSubstitutionStrategy(),
                    statistics.mean([hh.getConsumptionShare() for hh in self.households]),
                    statistics.mean([hh.getConsumptionDemand() for hh in self.households]),
                    
                    self.getStDevExpectedInflation(),
                    self.getStDevIndexationStrategy(),
                    self.getStDevSubstitutionStrategy()
                )
            
            Logger.debug(message)
