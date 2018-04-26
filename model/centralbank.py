#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""

Code for my master thesis.

Still under development.

@author: João Dimas (joaohenriqueavila@gmail.com)

"""
import statistics, random

class CentralBank:

    def __init__(self, economy):
        self.economy = economy
        self.pastNominalInterestRates = []

    def setNominalInterestRate(self):
        """ Equation (16) """
        # The paper says that the central bank sets current interest rate according to current inflation and unemployment. The current interest rate is used by households to make decisions of consumption in current period. Therefore, we need an interest rate before we can even calculate current inflation and current unemployment. For that reason, we are assuming that the Central Bank looks at the previous values of inflation and unemployment.
        nominalInterestRate = (1+self.economy.parameters.InflationTarget)*(1+self.economy.parameters.NaturalInterestRate)*((1+self.economy.goodsMarket.getPrevInflation())/(1+self.economy.parameters.InflationTarget))**self.economy.parameters.Phi_inflation*((1+self.economy.parameters.NaturalUnemploymentRate)/(1+self.economy.labourMarket.prevUnemploymentRate))**self.economy.parameters.Phi_unemployment-1
        
        if len(self.pastNominalInterestRates) > 1:
            # Based on the true data
            shockSD = 0.08 * statistics.stdev(self.pastNominalInterestRates)
            self.shock = random.gauss(0, shockSD)
            nominalInterestRate = nominalInterestRate + self.shock
            
        self.economy.nominalInterestRate = max(nominalInterestRate, self.economy.parameters.InterestLowerBound)
        
    def nextPeriod(self):
        self.pastNominalInterestRates.append(self.economy.nominalInterestRate)