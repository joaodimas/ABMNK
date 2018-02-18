#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""

Code for my master thesis.

Still under development.

@author: João Dimas (joaohenriqueavila@gmail.com)

"""
import math, random
from model.parameters import Parameters
from model.util.logger import Logger

class Household:

    def __init__(self, householdId, economy):
        self.householdId = householdId
        self.economy = economy
        self.pastRealIncomes = []
        self.pastEffectivelySuppliedLabour = []
        self.pastUtilities = []
        self.effectivelySuppliedLabour = None
        self.effectivelyConsumedGoods = None
        self.expectedInflation = None
        self.perceivedInflationTarget = None
        self.consumptionDemand = None
        self.consumptionShare = None
        self.currentIncome = None
        self.reservationWage = None
        self.permanentIncome = None
        self.smoothedUtility = None
        self.savingsBalance = None

        self.indexationStrategy = Parameters.InitialMeanIndexationStrategy
        self.substitutionStrategy = Parameters.InitialMeanSubstitutionStrategy
        self.prevIndexationStrategy = self.indexationStrategy
        self.prevSubstitutionStrategy = self.substitutionStrategy
        self.prevConsumptionShare = 0
        self.prevSavingsBalance = Parameters.InitialSavingsBalance
        self.prevWage = 0

    def getReservationWage(self):
        if self.reservationWage is None:
            if self.economy.currentPeriod == 1:
                # Not explicit in the model. We are assuming a random initial reservation wage.
                self.reservationWage = random.randint(Parameters.InitialReservationWageRange[0], Parameters.InitialReservationWageRange[1])
            else:
                """ Equation (1) """
                if self.getExpectedInflation() > 0:
                    self.reservationWage = self.prevWage * (1 + self.indexationStrategy * self.getExpectedInflation())
                else:
                    self.reservationWage = self.prevWage

        return self.reservationWage

    def getExpectedInflation(self):
        """ Equation (17) """
        if self.expectedInflation is None:
            self.expectedInflation = Parameters.Chi * self.getPerceivedInflationTarget() + (1 - Parameters.Chi) * self.economy.goodsMarket.getPastInflationTrend()

        return self.expectedInflation

    def getPerceivedInflationTarget(self):
        if self.perceivedInflationTarget is None:
            if Parameters.AllHouseholdsSameExpectation:
                self.perceivedInflationTarget = Parameters.InflationTarget + self.economy.getHomogeneousNoiseInflationTarget()
            else:
                self.perceivedInflationTarget = Parameters.InflationTarget + random.gauss(0,Parameters.NoiseInflationTargetPerceptionSD)

        return self.perceivedInflationTarget

    def getConsumptionDemand(self):
        """ Equation (2) """
        if self.consumptionDemand is None:
            self.consumptionDemand = self.getConsumptionShare() * self.getPermanentIncome()            
            if self.consumptionDemand < 0:
                #Logger.trace("Household {:d} has a negative demand. Setting it to 0.\nCons. demand: {:.2f}\nSupplied labour: {:.2f}\nRes. wage: {:.2f}\nIndex strat: {:.2f}\nSubs strat: {:.2f}\nPerm. income: {:.2f}\nCurrent income: {:.2f}\nPrev savings balance: {:.2f}", (self.householdId, self.consumptionDemand, self.effectivelySuppliedLabour, self.reservationWage, self.indexationStrategy, self.substitutionStrategy, self.permanentIncome, self.currentIncome, self.prevSavingsBalance), economy=self.economy)
                self.consumptionDemand = 0

        return self.consumptionDemand

    def getConsumptionShare(self):
        """ Equation (6) """
        if self.consumptionShare is None:
            self.consumptionShare = min(max(self.prevConsumptionShare - self.substitutionStrategy * (self.economy.nominalInterestRate - self.getExpectedInflation() - Parameters.NaturalInterestRate), Parameters.MinConsumptionShare), Parameters.MaxConsumptionShare)

        return self.consumptionShare

    def getPermanentIncome(self):
        """ Permanent income in Real terms """
        if self.permanentIncome is None:
            summation = self.getCurrentRealIncome()
            for l in range(1, len(self.pastRealIncomes)+1): # l = [1,20]
                summation = summation + Parameters.Ro ** l * self.pastRealIncomes[-l]
                assert l != 20 or self.pastRealIncomes[-l] == self.pastRealIncomes[0]
            self.permanentIncome = (1-Parameters.Ro)*summation
        return self.permanentIncome

    def getCurrentNominalIncome(self):
        """ Equation (4) """
        """ Current income in Nominal terms """
        if self.currentIncome is None:
            self.currentIncome = self.getReservationWage() * self.effectivelySuppliedLabour + self.economy.firm.getPrevProfitPerShare() + self.prevSavingsBalance * (1 + self.economy.prevInterestRate)
            #Logger.trace("[Household {:03d}] Current nominal income: {:.2f}", (self.householdId, self.currentIncome), economy=self.economy)

        return self.currentIncome

    def getLabourSupply(self):
        return Parameters.InnelasticLabourSupply

    def getSavingsBalance(self):
        if self.savingsBalance is None:
            self.savingsBalance = self.getCurrentNominalIncome() - self.effectivelyConsumedGoods * self.economy.goodsMarket.currentPrice
            if self.savingsBalance > Parameters.MaximumPrecision:
                raise ValueError("Nominal savings balance is above Python's mathematical precision. Aborting simulation.")
            
        return self.savingsBalance

    def getSmoothedUtility(self):
        """ Equation (7) """
        if self.smoothedUtility is None:
            summation = self.getUtility()
            for l in range(1, len(self.pastUtilities)+1): # l = [1,20]
                summation = summation + Parameters.Ro ** l * self.pastUtilities[-l]
                assert l != 20 or self.pastUtilities[-l] == self.pastUtilities[0]
            self.smoothedUtility = (1-Parameters.Ro)*summation
        return self.smoothedUtility

    def getUtility(self):
        # The paper does not specify what would happend when a household has 0 consumption. Since this might happen, and the log function is undefined for 0, we specify a fixed negative utility.
        return math.log(self.effectivelyConsumedGoods) if self.effectivelyConsumedGoods > 0 else -1000

    def imitateSomeone(self):
        other = self.selectHouseholdToImitate()
        self.indexationStrategy = other.prevIndexationStrategy
        self.substitutionStrategy = other.prevSubstitutionStrategy

        #Logger.trace("[Learning][Household {:03d}] Finished imitation. New indexation strategy: {:.2f}, new substitution strategy: {:.2f}.", (self.householdId, self.indexationStrategy, self.substitutionStrategy), economy=self.economy)

    def mutateRandomly(self):
        self.indexationStrategy = max(random.gauss(self.economy.getMeanIndexationStrategy(), Parameters.IndexationStrategySD), 0)
        self.substitutionStrategy = random.gauss(self.economy.getMeanSubstitutionStrategy(), Parameters.SubstitutionStrategySD)
        #Logger.trace("[Learning][Household {:03d}] Finished mutation. New indexation strategy: {:.2f}, new substitution strategy: {:.2f}.", (self.householdId, self.indexationStrategy, self.substitutionStrategy), economy=self.economy)

    def selectHouseholdToImitate(self):
        # Since the original paper is not explicit about this, we assume the following:
        # (i) Only the other households enter the selection function.
        # (ii) Households look at the values of utility in previous period, instead of current.
        #Logger.trace("[Learning][Household {:03d}] Selecting another household to imitate.", self.householdId, economy=self.economy)
        otherHouseholds = [hh for hh in self.economy.households if hh.householdId != self.householdId]
        #Logger.trace("[Learning][Household {:03d}] Will search among {:d} other households. Building cumulative distribution function.", (self.householdId, len(otherHouseholds)), economy=self.economy)
        households = []
        sumOfUtility = 0
        for hh in otherHouseholds:
            smoothedUtility = hh.getSmoothedUtility()
            #Logger.trace("[Learning][Household {:03d}] The smoothed utility of household {:03d} is: {:.2f}.", (self.householdId, hh.householdId, smoothedUtility), economy=self.economy)
            households.append({'household': hh, 'smoothedUtility': math.exp(smoothedUtility)})
            sumOfUtility = sumOfUtility + math.exp(hh.getSmoothedUtility())

        if sumOfUtility == 0: # No household had utility. Imitate self.
            return self

        #Logger.trace("[Learning][Household {:03d}] Sum of exp(smoothedUtility) is: {:.2f}.", (self.householdId, sumOfUtility), economy=self.economy)
        for hh in households:
            """ Equation (8) """
            hh['probability'] = hh['smoothedUtility']/sumOfUtility
            #Logger.trace("[Learning][Household {:03d}] The probability of choosing household {:03d} is: {:.2f}.", (self.householdId, hh['household'].householdId, hh['probability']), economy=self.economy)

        pointInCDF = random.random()
        #Logger.trace("[Learning][Household {:03d}] Randomly selected point in CDF is: {:.2f}.", (self.householdId, pointInCDF), economy=self.economy)

        sumOfProbabilities = 0
        #Logger.trace("[Learning][Household {:03d}] Iterating households' probabilities until we pass the selected point in CDF.", self.householdId, economy=self.economy)
        for hh in households:
            sumOfProbabilities = sumOfProbabilities + hh['probability']
            #Logger.trace("[Learning][Household {:03d}] Looking at household {:03d}, sum of probabilities so far: {:.2f}", (self.householdId, hh["household"].householdId, sumOfProbabilities), economy=self.economy)
            if sumOfProbabilities > pointInCDF:
                #Logger.trace("[Learning][Household {:03d}] We passed the selected point in CDF. Household {:03d} is chosen.", (self.householdId, hh["household"].householdId), economy=self.economy)
                return hh['household']

        assert False, "No household selected to imitate. Why?!"

    def learn(self):        
        #Logger.trace("[Learning][Household {:03d}] Learning. Imitate or mutate?", self.householdId, economy=self.economy)
        pointInCDF = random.random()
        if Parameters.ProbImitation >= pointInCDF:
            #Logger.trace("[Learning][Household {:03d}] Imitate someone!", self.householdId, economy=self.economy)
            self.imitateSomeone()
        elif Parameters.ProbImitation + Parameters.ProbMutation >= pointInCDF:
            #Logger.trace("[Learning][Household {:03d}] Mutate randomly!", self.householdId, economy=self.economy)
            self.mutateRandomly()
#        else:
            #Logger.trace("[Learning][Household {:03d}] None. Staying as he was.", self.householdId, economy=self.economy)

    def getCurrentRealIncome(self):
        return self.getCurrentNominalIncome() / self.economy.goodsMarket.currentPrice

    def nextPeriod(self):
        """ Prepare the object for a clean next period """
        self.pastEffectivelySuppliedLabour.append(self.effectivelySuppliedLabour)
        
        self.pastRealIncomes.append(self.getCurrentRealIncome())
        self.pastRealIncomes = self.pastRealIncomes[-Parameters.IncomeWindowOfObservation:]
        assert self.economy.currentPeriod <= Parameters.IncomeWindowOfObservation or len(self.pastRealIncomes) == Parameters.IncomeWindowOfObservation

        self.pastUtilities.append(self.getUtility())
        self.pastUtilities = self.pastUtilities[-Parameters.UtilityWindowOfObservation:]
        assert self.economy.currentPeriod <= Parameters.UtilityWindowOfObservation or len(self.pastUtilities) == Parameters.UtilityWindowOfObservation
            
        self.prevConsumptionShare = self.getConsumptionShare()
        self.prevSavingsBalance = self.getSavingsBalance()
        self.prevWage = self.reservationWage
        self.effectivelySuppliedLabour = None
        self.effectivelyConsumedGoods = None
        self.expectedInflation = None
        self.perceivedInflationTarget = None
        self.consumptionDemand = None
        self.consumptionShare = None
        self.currentIncome = None
        self.reservationWage = None
        self.permanentIncome = None
        self.smoothedUtility = None
        self.savingsBalance = None


