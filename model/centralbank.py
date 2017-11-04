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
        self.nominalInterestRate = None
        
    def getNominalInterestRate(self):
        """ Equation (16) """
        if self.nominalInterestRate is None:
            self.nominalInterestRate = (1+Parameters.InflationTarget)*(1+Parameters.NaturalInterestRate)*((1+self.economy.goodsMarket.getCurrentInflation())/(1+Parameters.InflationTarget))**Parameters.Phi_inflation*((1+Parameters.NaturalUnemploymentRate)/(1+self.economy.labourMarket.getUnemploymentRate()))**Parameters.Phi_unemployment
        return self.nominalInterestRate
    
    def nextPeriod(self):
        self.nominalInterestRate = None