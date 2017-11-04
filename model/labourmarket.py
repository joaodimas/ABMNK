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

from model.util.logger import Logger
from model.util.math import Math

class LabourMarket:
    
    def __init__(self, economy):
        self.economy = economy
    
    def getUnemploymentRate(self):
        return (len(self.economy.households) - self.aggregateHiredLabour)/len(self.economy.households)
            
    def getRealWageRate(self):
        realWageRate = self.getNominalWageRate()/self.economy.goodsMarket.currentPrice
        assert Math.isEquivalent(realWageRate, self.economy.firm.getTotalCost()/len(self.economy.households)/self.economy.goodsMarket.currentPrice), "realWageRate: {:.4f}. self.economy.firm.getTotalCost()/len(self.economy.households)/self.economy.goodsMarket.currentPrice: {:.4f}".format(realWageRate, self.economy.firm.getTotalCost()/len(self.economy.households)/self.economy.goodsMarket.currentPrice)
        return realWageRate
    
    def getNominalWageRate(self):
        nominalWageRate = sum([hh.getReservationWage() * hh.effectivelySuppliedLabour for hh in self.economy.households])/len(self.economy.households)
        return nominalWageRate
    
    def matchFirmAndWorkers(self):
        Logger.debug("[Labour market] Matching firms and workers", economy=self.economy)
        
        """ Equation (19) """
        demandedLabour = self.economy.firm.getLabourDemand()
        Logger.debug("[Labour market] Firm wants to hire {:.2f} units of labour.", demandedLabour, economy=self.economy)
        households = sorted(self.economy.households, key=lambda hh: hh.getReservationWage())
        Logger.trace("[Labour market] Firm sorted households by reservation wage.", economy=self.economy)
        
        hiredLabour = 0
        Logger.trace("[Labour market] Firm is iterating households.", economy=self.economy)
        for hh in households:
            Logger.trace("[Labour market] Household {:03d} wants to supply {:.2f} units of labour for a wage of {:.2f}. Expected inflation: {:.2%}. Hired labour so far: {:.2f}. Demanded labour: {:.2f}.", (hh.householdId, hh.getLabourSupply(), hh.getReservationWage(), hh.getExpectedInflation(), hiredLabour, demandedLabour), economy=self.economy)
            if hiredLabour >= demandedLabour:
                Logger.trace("[Labour market] No demand of labour for household {:03d}. He is not hired.", hh.householdId, economy=self.economy)
                hh.effectivelySuppliedLabour = 0
                continue
            
            """ Equation (18) """
            hiredLabour = hiredLabour + hh.getLabourSupply()
            hh.effectivelySuppliedLabour = hh.getLabourSupply()
            # what about excess supply of the last hired household?
            if hiredLabour > demandedLabour:
                excess = hiredLabour - demandedLabour
                hh.effectivelySuppliedLabour = hh.effectivelySuppliedLabour - excess
                hiredLabour = demandedLabour
                Logger.trace("[Labour market] Household {:03d} wants to supply {:.2f} units of labour but the firm requires only {:.2f} more, so he works less than he wants.", (hh.householdId, hh.getLabourSupply(), hh.getLabourSupply()-excess), economy=self.economy)

            Logger.debug("[Labour market] Household {:03d} is hired for {:.2f} units of labour. Wage: {:.2f}. Expected inflation: {:.2%}", (hh.householdId, hh.effectivelySuppliedLabour, hh.getReservationWage(), hh.getExpectedInflation()), economy=self.economy)
        self.aggregateHiredLabour = hiredLabour        
        Logger.debug("[Labour market] Finished matching firms and workers. Hired labour: {:.2f}", hiredLabour, economy=self.economy)
            
