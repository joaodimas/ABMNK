#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Oct 24 19:03:35 2017

@author: João Dimas and Umberto Collodel
"""

class LabourMarket:
    
    def __init__(self, economy):
        self.economy = economy
    
    def getUnemploymentRate(self):
        return (self.economy.getNumberOfHouseholds() - self.getAggregateHiredLabour())/self.economy.getNumberOfHouseholds()
    
    def getAggregateHiredLabour(self):
        return sum([hh.effectivelySuppliedLabour for hh in self.economy.households])
        
    def getRealWageRate(self):
        return sum([hh.effectivelySuppliedLabour * hh.getReservationWage() for hh in self.economy.households])/self.economy.goodsMarket.getCurrentPrice()
    
    def matchFirmAndWorkers(self):
        """ Equation (19) """
        demandedLabour = self.economy.firm.getLabourDemand()
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
            
