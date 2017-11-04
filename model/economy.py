#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Project for course Quantitative Methods in Finance, Prof. Eric Vansteenberghe.
Université Paris 1 Panthéon-Sorbonne
Program: Master 2 Financial Economics, 2017.
Authors: João Dimas (joaohenriqueavila@gmail.com) and Umberto Collodel (umberto.collodel@gmail.com)

Replication of an agent-based model described in:
Salle, I., Yıldızoğlu, M., & Sénégas, M.-A. (2013). Inflation targeting in a learning economy: An ABM perspective. Economic Modelling, 34, 114–128.
"""

from model.labourmarket import LabourMarket
from model.goodsmarket import GoodsMarket
from model.centralbank import CentralBank
from model.firm import Firm
from model.household import Household
from model.parameters import Parameters
from model.util.logger import Logger

class Economy:
    def __init__(self, simulationNumber):
        Logger.debug("Initializing Economy")
        self.simulationNumber = simulationNumber
        self.currentPeriod = 0       
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
        
        # TODO: We are assuming that initially all households choose random strategies based on initial mean values set in Parameters.
        Logger.debug("Households are mutating randomly to define their initial strategies")
        for hh in self.households:
            hh.mutateRandomly()
        
        # Only used if Parameters.AllHouseholdsSameExpectation == True
        self.homogeneousNoiseInflationTarget = None
         
    def runCurrentPeriod(self):
        Logger.info("", economy=self)
        Logger.info("SIMULATING CURRENT PERIOD", economy=self)
        self.labourMarket.matchFirmAndWorkers()
        self.goodsMarket.matchFirmAndWorkers()
        
        # We store the current strategies in different variables because households imitate the behaviour of past period. This will be used in the learn() function.
        for hh in self.households:
            hh.prevIndexationStrategy = hh.indexationStrategy
            hh.prevSubstitutionStrategy = hh.substitutionStrategy        

        Logger.debug("[Learning] Households are learning.", economy=self)
        for hh in self.households:
            hh.learn() # Mutate or imitate

    def nextPeriod(self):
        """ Prepare the object for a clean next period """
        Logger.info("Preparing next period.", economy=self)
        for hh in self.households:
            hh.nextPeriod()
        
        self.firm.nextPeriod()
        self.goodsMarket.nextPeriod()
        self.centralBank.nextPeriod()
        self.currentPeriod = self.currentPeriod + 1
        self.homogeneousNoiseInflationTarget = None
        
    def describeCurrentPeriod(self):
        Logger.info("", economy=self)
        Logger.info("RESULTS OF CURRENT PERIOD", economy=self)
        Logger.info("----------------------------", economy=self)
        Logger.info("Unemployment rate: {:.2%}",self.labourMarket.getUnemploymentRate(), economy=self)
        Logger.info("Inflation: {:.2%}",self.goodsMarket.getCurrentInflation(), economy=self)
        Logger.info("Price: {:.2f}",self.goodsMarket.currentPrice, economy=self)
        Logger.info("Interest rate: {:.2%}",self.centralBank.getNominalInterestRate(), economy=self)
        Logger.info("Production: {:.2f}",self.firm.getProduction(), economy=self)
        Logger.info("Hired labour: {:.2f}",self.labourMarket.aggregateHiredLabour, economy=self)
        Logger.info("Total cost: {:.2f}",self.firm.getTotalCost(), economy=self)
        Logger.info("Total revenue: {:.2f}",self.goodsMarket.aggregateSoldGoods*self.goodsMarket.currentPrice, economy=self)
        Logger.info("Total profit: {:.2f}",self.firm.getProfit(), economy=self)
        Logger.info("Goods sold: {:.2f}", self.goodsMarket.aggregateSoldGoods, economy=self)
        Logger.info("Nominal wage rate: {:.2f}",self.labourMarket.getNominalWageRate(), economy=self)
        Logger.info("Real wage rate: {:.2f}",self.labourMarket.getRealWageRate(), economy=self)
        Logger.info("----------------------------", economy=self)