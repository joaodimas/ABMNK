#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Project for course Quantitative Methods in Finance, Prof. Eric Vansteenberghe.
Université Paris 1 Panthéon-Sorbonne
Program: Master 2 Financial Economics, 2017.
Authors: João Dimas (joaohenriqueavila@gmail.com) and Umberto Collodel (umberto.collodel@gmail.com)

Replication of an agent-based model described in:
Salle, I., Yıldızoğlu, M., & Sénégas, M.-A. (2013). Inflation targeting in a learning economy: An ABM perspective. Economic Modelling, 34, 114–128.

Technical information on README.md

"""

from model.labourmarket import LabourMarket
from model.goodsmarket import GoodsMarket
from model.centralbank import CentralBank
from model.firm import Firm
from model.household import Household
from model.parameters import Parameters
from model.util.logger import Logger
import random, statistics

class Economy:
    def __init__(self, simulationNumber):
        Logger.trace("Initializing Economy")
        self.simulationNumber = simulationNumber
        self.prevInterestRate = 0

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
        Logger.trace("Households are mutating randomly to define their initial strategies")
        if Parameters.ProbMutation > 0:
            for hh in self.households:
                hh.mutateRandomly()

        # Only used if Parameters.AllHouseholdsSameExpectation == True
        self.homogeneousNoiseInflationTarget = None

    def runCurrentPeriod(self):
        Logger.debug("", economy=self)
        Logger.info("SIMULATING CURRENT PERIOD", economy=self)
        self.centralBank.setNominalInterestRate()
        self.labourMarket.matchFirmAndWorkers()
        self.goodsMarket.matchFirmAndConsumers()

        # We store the current strategies in different variables because households imitate the behaviour of past period. This will be used in the learn() function.
        for hh in self.households:
            hh.prevIndexationStrategy = hh.indexationStrategy
            hh.prevSubstitutionStrategy = hh.substitutionStrategy

        Logger.trace("[Learning] Households are learning.", economy=self)
        for hh in self.households:
            hh.learn() # Mutate or imitate

    def nextPeriod(self):
        """ Prepare the object for a clean next period """
        Logger.debug("Preparing next period.", economy=self)
        for hh in self.households:
            hh.nextPeriod()

        self.firm.nextPeriod()
        self.goodsMarket.nextPeriod()
        self.labourMarket.nextPeriod()
        self.currentPeriod = self.currentPeriod + 1
        self.homogeneousNoiseInflationTarget = None
        self.prevInterestRate = self.nominalInterestRate

    def getHomogeneousNoiseInflationTarget(self):
        if self.homogeneousNoiseInflationTarget is None:
            self.homogeneousNoiseInflationTarget = random.gauss(0,Parameters.NoiseInflationTargetPerceptionSD)

        return self.homogeneousNoiseInflationTarget

    def describeCurrentPeriod(self):
        
        Logger.debug(""" 
            RESULTS OF CURRENT PERIOD
            ----------------------------
            Hired workers: {:.2f}
            Unemployed workers: {:.2f}
            Unemployment rate: {:.2%}
            Production: {:.2f}
            Goods sold: {:.2f}
            Excess supply: {:.2f}
            Price: {:.2f}
            Inflation: {:.2%}
            Mean expected inflation: {:.2%}
            Std dev expected inflation: {:.2f}
            Interest rate: {:.2%}
            Total cost: {:.2f}
            Total revenue: {:.2f}
            Total profit (nominal): {:.2f}
            Total profit (real): {:.2f}
            Wage rate (nominal): {:.2f}
            Wage rate (real): {:.2f}
            Mean perm. income (real): {:.2f}
            Mean current income (real): {:.2f}
            Mean savings (real): {:.2f}
            Mean index. strat: {:.2f}
            Mean subs. strat: {:.2f}
            Mean cons. share: {:.2f}
            Mean cons. demand: {:.2f}
            Std dev perm. income (real): {:.2f}
            Std dev current income (real): {:.2f}
            Std dev savings (real): {:.2f}
            Std dev index. strat: {:.2f}
            Std dev subs. strat: {:.2f}
            Std dev cons. share: {:.2f}
            Std dev cons. demand: {:.2f}
            ----------------------------
        """, (
                self.labourMarket.aggregateHiredLabour,
                len(self.households)-self.labourMarket.aggregateHiredLabour,
                self.labourMarket.getUnemploymentRate(),
                self.firm.getProduction(),
                self.goodsMarket.aggregateSoldGoods,
                self.firm.getProduction()-self.goodsMarket.aggregateSoldGoods,
                self.goodsMarket.currentPrice,
                self.goodsMarket.getCurrentInflation(),
                statistics.mean([hh.getExpectedInflation() for hh in self.households]),
                statistics.stdev([hh.getExpectedInflation() for hh in self.households]),
                self.nominalInterestRate,
                self.firm.getTotalCost(),
                self.goodsMarket.aggregateSoldGoods*self.goodsMarket.currentPrice,
                self.firm.getProfit(),
                self.firm.getProfit()/self.goodsMarket.currentPrice,
                self.labourMarket.getNominalWageRate(),
                self.labourMarket.getRealWageRate(),
                statistics.mean([hh.getPermanentIncome() for hh in self.households]),
                statistics.mean([hh.getCurrentNominalIncome()/self.goodsMarket.currentPrice for hh in self.households]),
                statistics.mean([hh.getSavingsBalance()/self.goodsMarket.currentPrice for hh in self.households]),
                statistics.mean([hh.indexationStrategy for hh in self.households]),
                statistics.mean([hh.substitutionStrategy for hh in self.households]),
                statistics.mean([hh.getConsumptionShare() for hh in self.households]),
                statistics.mean([hh.getConsumptionDemand() for hh in self.households]),
                statistics.stdev([hh.getPermanentIncome() for hh in self.households]),
                statistics.stdev([hh.getCurrentNominalIncome()/self.goodsMarket.currentPrice for hh in self.households]),
                statistics.stdev([hh.getSavingsBalance()/self.goodsMarket.currentPrice for hh in self.households]),
                statistics.stdev([hh.indexationStrategy for hh in self.households]),
                statistics.stdev([hh.substitutionStrategy for hh in self.households]),
                statistics.stdev([hh.getConsumptionShare() for hh in self.households]),
                statistics.stdev([hh.getConsumptionDemand() for hh in self.households])
            ), economy=self)