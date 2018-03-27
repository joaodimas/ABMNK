#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""

Code for my master thesis.

Still under development.

@author: João Dimas (joaohenriqueavila@gmail.com)

"""
import math, random

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

        self.indexationStrategy = self.economy.parameters.InitialMeanIndexationStrategy
        self.substitutionStrategy = self.economy.parameters.InitialMeanSubstitutionStrategy
        self.prevIndexationStrategy = self.indexationStrategy
        self.prevSubstitutionStrategy = self.substitutionStrategy
        self.prevConsumptionShare = 0
        self.prevSavingsBalance = self.economy.parameters.InitialSavingsBalance
        self.prevWage = 0

    def getReservationWage(self):
        if self.reservationWage is None:
            if self.economy.currentPeriod == 1:
                # Not explicit in the model. We are assuming a random initial reservation wage.
                self.reservationWage =self.economy.parameters.InitialReservationWage
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
            self.expectedInflation = self.economy.parameters.Chi * self.getPerceivedInflationTarget() + (1 - self.economy.parameters.Chi) * self.economy.goodsMarket.getPastInflationTrend()

        return self.expectedInflation

    def getPerceivedInflationTarget(self):
        if self.perceivedInflationTarget is None:
            if self.economy.parameters.HouseholdCoordination:
                self.perceivedInflationTarget = self.economy.parameters.InflationTarget + self.economy.getHomogeneousNoiseInflationTarget()
            else:
                self.perceivedInflationTarget = self.economy.parameters.InflationTarget + random.gauss(0,self.economy.parameters.Sigma_xi/len(self.economy.households))

        return self.perceivedInflationTarget

    def getConsumptionDemand(self):
        """ Equation (2) """
        if self.consumptionDemand is None:
            self.consumptionDemand = self.getConsumptionShare() * self.getPermanentIncome()            
            if self.consumptionDemand < 0:
                self.consumptionDemand = 0

        return self.consumptionDemand

    def getConsumptionShare(self):
        """ Equation (6) """
        if self.consumptionShare is None:
            self.consumptionShare = min(max(self.prevConsumptionShare - self.substitutionStrategy * (self.economy.nominalInterestRate - self.getExpectedInflation() - self.economy.parameters.NaturalInterestRate), self.economy.parameters.MinConsumptionShare), self.economy.parameters.MaxConsumptionShare)

        return self.consumptionShare

    def getPermanentIncome(self):
        """ Permanent income in Real terms """
        if self.permanentIncome is None:
            summation = self.getCurrentRealIncome()
            for l in range(1, len(self.pastRealIncomes)+1): # l = [1,20]
                summation = summation + self.economy.parameters.Ro ** l * self.pastRealIncomes[-l]
#                assert l != 20 or self.pastRealIncomes[-l] == self.pastRealIncomes[0]
            self.permanentIncome = (1-self.economy.parameters.Ro)*summation
        return self.permanentIncome

    def getCurrentNominalIncome(self):
        """ Equation (4) """
        """ Current income in Nominal terms """
        if self.currentIncome is None:
            self.currentIncome = self.getReservationWage() * self.effectivelySuppliedLabour + self.economy.firm.getPrevProfitPerShare() + self.prevSavingsBalance * (1 + self.economy.prevInterestRate)

        return self.currentIncome

    def getLabourSupply(self):
        return self.economy.parameters.InnelasticLabourSupply

    def getSavingsBalance(self):
        if self.savingsBalance is None:
            self.savingsBalance = self.getCurrentNominalIncome() - self.effectivelyConsumedGoods * self.economy.goodsMarket.currentPrice
            if self.savingsBalance > self.economy.parameters.MaximumPrecision:
                raise ValueError("Nominal savings balance is above Python's mathematical precision. Aborting simulation.")
            
        return self.savingsBalance

    def getSmoothedUtility(self):
        """ Equation (7) """
        if self.smoothedUtility is None:
            summation = self.getUtility()
            for l in range(1, len(self.pastUtilities)+1): # l = [1,20]
                summation = summation + self.economy.parameters.Ro ** l * self.pastUtilities[-l]
#                assert l != 20 or self.pastUtilities[-l] == self.pastUtilities[0]
            self.smoothedUtility = (1-self.economy.parameters.Ro)*summation
        return self.smoothedUtility

    def getUtility(self):
        # The paper does not specify what would happend when a household has 0 consumption. Since this might happen, and the log function is undefined for 0, we specify a fixed negative utility.
        return math.log(self.effectivelyConsumedGoods) if self.effectivelyConsumedGoods > 0 else -2

    def imitateSomeone(self):
        other = self.selectHouseholdToImitate()
        self.indexationStrategy = other.prevIndexationStrategy
        self.substitutionStrategy = other.prevSubstitutionStrategy

    def mutateRandomly(self):
        self.indexationStrategy = max(random.gauss(self.economy.getMeanIndexationStrategy(), self.economy.parameters.Sigma_mutW), 0)
        self.substitutionStrategy = random.gauss(self.economy.getMeanSubstitutionStrategy(), self.economy.parameters.Sigma_mutK)

    def selectHouseholdToImitate(self):
        # Since the original paper is not explicit about this, we assume the following:
        # (i) Only the other households enter the selection function.
        # (ii) Households look at the values of utility in previous period, instead of current.
        otherHouseholds = [hh for hh in self.economy.households if hh.householdId != self.householdId]
        households = []
        sumOfUtility = 0
        for hh in otherHouseholds:
            smoothedUtility = hh.getSmoothedUtility()
            households.append({'household': hh, 'smoothedUtility': math.exp(smoothedUtility)})
            sumOfUtility = sumOfUtility + math.exp(hh.getSmoothedUtility())

        if sumOfUtility == 0: # No household had utility. Imitate self.
            return self

        for hh in households:
            """ Equation (8) """
            hh['probability'] = hh['smoothedUtility']/sumOfUtility

        pointInCDF = random.random()

        sumOfProbabilities = 0
        for hh in households:
            sumOfProbabilities = sumOfProbabilities + hh['probability']
            if sumOfProbabilities > pointInCDF:
                return hh['household']

        assert False, "No household selected to imitate. Why?!. pointInCDF: {:.2f}, sumOfUtility: {:.2f}, sumOfProbabilities: {:.2f}, priceLevel: {:.2f}".format(pointInCDF, sumOfUtility, sumOfProbabilities, self.economy.goodsMarket.currentPrice)

    def learn(self):        
        pointInCDF = random.random()
        if self.economy.parameters.ProbImitation >= pointInCDF:
            self.imitateSomeone()
        elif self.economy.parameters.ProbImitation + self.economy.parameters.ProbMutation >= pointInCDF:
            self.mutateRandomly()

    def getCurrentRealIncome(self):
        return self.getCurrentNominalIncome() / self.economy.goodsMarket.currentPrice

    def nextPeriod(self):
        """ Prepare the object for a clean next period """
        self.pastEffectivelySuppliedLabour.append(self.effectivelySuppliedLabour)
        
        self.pastRealIncomes.append(self.getCurrentRealIncome())
        self.pastRealIncomes = self.pastRealIncomes[-self.economy.parameters.IncomeWindowOfObservation:]
#        assert self.economy.currentPeriod <= self.economy.parameters.IncomeWindowOfObservation or len(self.pastRealIncomes) == self.economy.parameters.IncomeWindowOfObservation

        self.pastUtilities.append(self.getUtility())
        self.pastUtilities = self.pastUtilities[-self.economy.parameters.UtilityWindowOfObservation:]
#        assert self.economy.currentPeriod <= self.economy.parameters.UtilityWindowOfObservation or len(self.pastUtilities) == self.economy.parameters.UtilityWindowOfObservation
            
        self.prevConsumptionShare = self.getConsumptionShare()
        self.prevSavingsBalance = self.getSavingsBalance()
        self.prevWage = self.reservationWage
        self.effectivelySuppliedLabour = None
        self.effectivelyConsumedGoods = None
        self.expectedInflation = None
        self.consumptionDemand = None
        self.consumptionShare = None
        self.currentIncome = None
        self.reservationWage = None
        self.permanentIncome = None
        self.smoothedUtility = None
        self.savingsBalance = None


