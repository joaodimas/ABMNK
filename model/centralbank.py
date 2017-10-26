#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Oct 25 14:58:22 2017

@author: João Dimas and Umberto Collodel
"""
from model.parameters import Parameters

class CentralBank:
    
    def __init__(self, economy):
        self.economy = economy
        
    def getInterestRate(self):
        """ Equation (16) """
        return (1+Parameters.InflationTarget)*(1+Parameters.NaturalInterestRate)*((1+self.economy.goodsMarket.getCurrentInflation())/(1+Parameters.InflationTarget))**Parameters.Phi_inflation*((1+Parameters.NaturalUnemploymentRate)/(1+self.economy.labourMarket.getUnemploymentRate()))**Parameters.Phi_unemployment