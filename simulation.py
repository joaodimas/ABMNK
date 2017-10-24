#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Oct 24 16:43:26 2017

@author: jdimas
"""
from model.economy import Economy
from model.household import Household
from model.parameters import Parameters

# Simulation
Parameters.setInitialParameters()
economy = Economy(Parameters.InitialPriceLevel)
for i in range(Parameters.NmbHouseholds):
    householdId = i+1
    household = Household(householdId, economy)
    economy.households.append(household)
    
#print(len(economy.households))

print(economy.households[2].getPermanentIncome())