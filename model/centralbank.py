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
from model.parameters import Parameters

class CentralBank:

    def __init__(self, economy):
        self.economy = economy
        self.prevInterestRate = 0

    def setNominalInterestRate(self):
        """ Equation (16) """
        # TODO: The paper says that the central bank sets current interest rate according to current inflation and unemployment. The current interest rate is used by households to make decisions of consumption in current period. Therefore, we need an interest rate before we can even calculate current inflation and current unemployment. For that reason, we are assuming that the Central Bank looks at the previous values of inflation and unemployment.
        self.nominalInterestRate = (1+Parameters.InflationTarget)*(1+Parameters.NaturalInterestRate)*((1+self.economy.goodsMarket.getPrevInflation())/(1+Parameters.InflationTarget))**Parameters.Phi_inflation*((1+Parameters.NaturalUnemploymentRate)/(1+self.economy.labourMarket.prevUnemploymentRate))**Parameters.Phi_unemployment-1

    def nextPeriod(self):
        self.nominalInterestRate = None