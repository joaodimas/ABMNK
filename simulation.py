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
from model.economy import Economy
from model.parameters import Parameters
from model.data import PeriodData
from model.util.export_to_csv import ExportToCSV
from model.util.logger import Logger
import datetime, cProfile, io, pstats, os, time

class SystemConfig:
    LogLevel = {"Console": ["INFO"], "File":["INFO"]}
    EnableProfilingMainThread = False
    
def describeModelParameters():
    parameters = {}
    obj = Parameters()
    members = [attr for attr in dir(obj) if not callable(getattr(obj, attr)) and not attr.startswith("__")]
    for member in members:
        parameters[member] = getattr(obj, member)

    desc = ""
    for key, value in parameters.items():
        desc += key + ": " + str(value) + "\n"

    return desc

if __name__ == '__main__':
    
    pr = None
    if(SystemConfig.EnableProfilingMainThread):
        pr = cProfile.Profile()
        pr.enable()
        
    try:
        timestamp = datetime.datetime.now()
        Logger.initialize(timestamp, SystemConfig.LogLevel)
        # Simulation
        Parameters.init()
        parameters = describeModelParameters()
        Logger.info(parameters)
        THIS_FOLDER = os.path.dirname(os.path.abspath(__file__))
        with open(os.path.join(THIS_FOLDER, "./data/ABMNK."+timestamp.strftime("%Y-%m-%dT%Hh%Mm%Ss")+".params.txt"), "w", newline='') as f:
            print(parameters, file=f)
        
        simulationNumber = 1 # Possible extension: multiple simulations to average the results.
        
        Logger.info("Starting simulation {:d}".format(simulationNumber))

        allPeriodsData = [PeriodData.getHeader()]
        # Create a virtual economy with agents
        simulationStartTime = time.time()
        economy = Economy(1)
        for t in range(Parameters.Periods):
            economy.runCurrentPeriod()
            allPeriodsData.append(PeriodData.getCurrentPeriodData(economy))
            economy.describeCurrentPeriod()
            economy.nextPeriod()
        simulationEndTime = time.time()
            
        Logger.info("Simulation completed in {:.2f} seconds", (simulationEndTime - simulationStartTime))
        Logger.info("Saving data...")
        ExportToCSV.exportTimeSeriesData(allPeriodsData, timestamp, simulationNumber)
        Logger.info("ALL PROCESSES FINISHED!")
        
    except Exception as e:
        Logger.logger.exception("Error")
        raise e
            
    if(SystemConfig.EnableProfilingMainThread):
        pr.disable()
        with io.StringIO() as s:
            ps = pstats.Stats(pr, stream=s).sort_stats('tottime')
            ps.print_stats()
            Logger.info(s.getvalue())