#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Oct 24 16:43:26 2017

@author: João Dimas and Umberto Collodel
"""
from model.economy import Economy
from model.parameters import Parameters
from model.data import PeriodData
from model.util.export_to_csv import ExportToCSV

# Simulation
Parameters.init()
simulationNumber = 1

# Create a virtual economy with agents
economy = Economy(1)

allPeriodsData = ["var1", "var2", "var3"] # TODO: CSV header
for t in Parameters.Periods:
    economy.runCurrentPeriod()
    allPeriodsData.append(PeriodData.getCurrentPeriodData(economy))
    economy.nextPeriod()
    
ExportToCSV.exportTimeSeriesData(allPeriodsData)