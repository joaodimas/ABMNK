#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""

Code for my master thesis.

Still under development.

@author: João Dimas (joaohenriqueavila@gmail.com)

"""
from model.parameters import Parameters

class CentralBank:

    def __init__(self, economy):
        self.economy = economy

    def setNominalInterestRate(self):
        """ Equation (16) """
        # The paper says that the central bank sets current interest rate according to current inflation and unemployment. The current interest rate is used by households to make decisions of consumption in current period. Therefore, we need an interest rate before we can even calculate current inflation and current unemployment. For that reason, we are assuming that the Central Bank looks at the previous values of inflation and unemployment.
        self.economy.nominalInterestRate = max((1+Parameters.InflationTarget)*(1+Parameters.NaturalInterestRate)*((1+self.economy.goodsMarket.getPrevInflation())/(1+Parameters.InflationTarget))**Parameters.Phi_inflation*((1+Parameters.NaturalUnemploymentRate)/(1+self.economy.labourMarket.prevUnemploymentRate))**Parameters.Phi_unemployment-1, Parameters.InterestLowerBound)
        