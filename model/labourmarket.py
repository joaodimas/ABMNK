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

from model.util.logger import Logger
from model.util.math import Math
from model.parameters import Parameters
import math

class LabourMarket:

    def __init__(self, economy):
        self.economy = economy
        self.unemploymentRate = None
        self.nominalWageRate = None
        self.prevUnemploymentRate = 0

    def getUnemploymentRate(self):
        if self.unemploymentRate is None:
            self.unemploymentRate = (len(self.economy.households) - self.aggregateHiredLabour)/len(self.economy.households)

        return self.unemploymentRate

    def getRealWageRate(self):
        realWageRate = self.getNominalWageRate()/self.economy.goodsMarket.currentPrice
        
        if not (math.isinf(realWageRate) or math.isnan(realWageRate)):
            assert Math.isEquivalent(realWageRate, (1-Parameters.Alpha)/(1+Parameters.Mu)*self.aggregateHiredLabour**(-Parameters.Alpha)), "nominalWage: {:.4f}. realWageRate: {:.4f}. (1-Parameters.Alpha)/(1+Parameters.Mu)*self.aggregateHiredLabour**(-Parameters.Alpha): {:.4f}".format(self.getNominalWageRate(), realWageRate, (1-Parameters.Alpha)/(1+Parameters.Mu)*self.aggregateHiredLabour**(-Parameters.Alpha))
        return realWageRate

    def getNominalWageRate(self):
        if self.nominalWageRate is None:
            self.nominalWageRate = sum([hh.getReservationWage() * hh.effectivelySuppliedLabour for hh in self.economy.households])/self.aggregateHiredLabour
        return self.nominalWageRate

    def matchFirmAndWorkers(self):
        Logger.trace("[Labour market] Matching firms and workers", economy=self.economy)

        # TODO: Assumption: hired labour can be a decimal number for any worker.

        """ Equation (19) """
        demandedLabour = self.economy.firm.labourDemand
        Logger.trace("[Labour market] Firm wants to hire {:.2f} units of labour.", demandedLabour, economy=self.economy)
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

            Logger.trace("[Labour market] Household {:03d} is hired for {:.2f} units of labour. Wage: {:.2f}. Expected inflation: {:.2%}", (hh.householdId, hh.effectivelySuppliedLabour, hh.getReservationWage(), hh.getExpectedInflation()), economy=self.economy)
        self.aggregateHiredLabour = hiredLabour
        Logger.trace("[Labour market] Finished matching firms and workers. Hired labour: {:.2f}", hiredLabour, economy=self.economy)

    def nextPeriod(self):
        self.prevUnemploymentRate = self.unemploymentRate
        self.unemploymentRate = None
        self.nominalWageRate = None