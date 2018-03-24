#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""

Code for my master thesis.

Still under development.

@author: João Dimas (joaohenriqueavila@gmail.com)

"""


class LabourMarket:

    def __init__(self, economy):
        self.economy = economy
        self.unemploymentRate = None
        self.nominalWageRate = None
        self.totalLabourSupply = None
        self.prevUnemploymentRate = 0

    def getUnemploymentRate(self):
        if self.unemploymentRate is None:
            self.unemploymentRate = (len(self.economy.households) - self.aggregateHiredLabour)/len(self.economy.households)

        return self.unemploymentRate
    
    def getTotalLabourSupply(self):
        if self.totalLabourSupply is None:
            self.totalLabourSupply = sum([hh.getLabourSupply() for hh in self.economy.households])
            
        return self.totalLabourSupply

    def getRealWageRate(self):
        realWageRate = self.getNominalWageRate()/self.economy.goodsMarket.currentPrice
        
        return realWageRate

    def getNominalWageRate(self):
        if self.nominalWageRate is None:
            self.nominalWageRate = sum([hh.getReservationWage() * hh.effectivelySuppliedLabour for hh in self.economy.households])/self.aggregateHiredLabour
        return self.nominalWageRate

    def matchFirmAndWorkers(self):

        # Assumption: hired labour can be a decimal number for any worker.

        """ Equation (19) """
        demandedLabour = self.economy.firm.labourDemand
        households = sorted(self.economy.households, key=lambda hh: hh.getReservationWage())

        hiredLabour = 0
        for hh in households:
            if hiredLabour >= demandedLabour:
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

        self.aggregateHiredLabour = hiredLabour

    def nextPeriod(self):
        self.prevUnemploymentRate = self.getUnemploymentRate()
        self.unemploymentRate = None
        self.nominalWageRate = None
        self.totalLabourSupply = None