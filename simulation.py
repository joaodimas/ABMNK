#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""

Code for my master thesis.

Still under development.

@author: João Dimas (joaohenriqueavila@gmail.com)

"""
from model.economy import Economy
from model.parameters import Parameters
from model.resultsdata import ResultsData
from model.util.export_to_csv import ExportToCSV
from model.util.logger import Logger
import datetime, os, time, multiprocessing, operator

class SystemConfig:
    LogLevel = {"Console": ["INFO"], "File":[""]} # Set INFO, DEBUG or TRACE for Console and File.

    NumberOfSimulations = 500 # Number of independent executions.
    NumberOfParallelProcesses = 60 # Number of parallel processes.
    PauseInterval = None

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

def checkPause(economy, t):
    if SystemConfig.PauseInterval is not None and t % SystemConfig.PauseInterval == 0:
        command = None
        while command != "":
            try:
                command = input("God mode: ")
                if command != "":
                    if command.isdigit():
                        SystemConfig.PauseInterval = int(command)
                        print("New pause interval: {:d}".format(SystemConfig.PauseInterval))
                    elif "=" in command or "(" in command: 
                        if hasattr(economy, command.split(" =")[0]) or hasattr(economy, command.split("=")[0]) or hasattr(economy, command.split("(")[0]) or hasattr(economy, command.split(".")[0]):
                            exec("economy." + command)
                        else:
                            exec(command)
                    elif hasattr(Parameters, command):
                        print(eval("Parameters." + command))
                    elif hasattr(economy, command) or hasattr(economy, command.split(".")[0]):
                        print(eval("economy."+ command))
                    else:
                        print(eval(command))
            except Exception as ex:
                print(ex)

def simulate(simulationNumber):
    try:
        granularResults = []
        runStartTime = time.time()

        Logger.info("Starting run {:d}.".format(simulationNumber))

        # Create a virtual economy with heterogeneous agents
        economy = Economy(simulationNumber)
        for t in range(1,Parameters.Periods+1):
            
            checkPause(economy, t)
            Logger.info("[SIMULATION {:03d}][PERIOD {:03d}] Simulating...".format(simulationNumber, t))            
            economy.runCurrentPeriod()
            granularResults.append(ResultsData.getCurrentPeriodData(economy))
            economy.describeCurrentPeriod()
            economy.nextPeriod()

        Logger.info("Simulation completed in {:.2f} seconds. Simulation number: {:d}.", ((time.time() - runStartTime), simulationNumber))
        return granularResults
    except ValueError as e:
        Logger.logger.exception(e)
        raise e
    except Exception as e:
        Logger.logger.exception("Error")
        raise e

# MAIN EXECUTION THREAD
if __name__ == '__main__':

    try:
        generalTimestamp = datetime.datetime.now()
        granularResults = []
        aggregateStartTime = time.time()
        Logger.initialize(generalTimestamp, SystemConfig.LogLevel)

        Parameters.init()

        # Saving parameters to file.
        parameters = describeModelParameters()
        Logger.info(parameters)
        THIS_FOLDER = os.path.dirname(os.path.abspath(__file__))
        with open(os.path.join(THIS_FOLDER, ("./data/ABMNK.{}.params.txt").format(generalTimestamp.strftime("%Y-%m-%dT%Hh%Mm%Ss"))), "w", newline='') as f:
            print(parameters, file=f)

        processes = []
        
        if SystemConfig.NumberOfSimulations > 1:
            # Start a parallel process to execute each run.
            pool = multiprocessing.Pool(SystemConfig.NumberOfParallelProcesses)
            # Run function simulate in parallel for each independent execution and aggregate results.
            listOfResults = pool.imap_unordered(simulate, range(1,SystemConfig.NumberOfSimulations+1)) 
            # Append results
            for result in listOfResults:
                if len(result) > 0:
                    granularResults = granularResults + result
        else:
            granularResults = simulate(1)

        # Sort results by Run, Period. Then, add header.
        granularResults = [ResultsData.getHeader()] + sorted(granularResults, key=operator.itemgetter(0,1))

        Logger.info("All simulations completed. Total time {:.2f} seconds.", time.time() - aggregateStartTime)
        Logger.info("Saving granular data...")
        ExportToCSV.exportGranularData(granularResults, generalTimestamp)

        if len(granularResults) > 2:
            Logger.info("Saving aggregate statistics...")
            aggregateStatistics = ResultsData.getAggregateStatistics(granularResults)
            ExportToCSV.exportAggregateStatistics(aggregateStatistics, generalTimestamp)

        Logger.info("ALL PROCESSES FINISHED!")
    except Exception as e:
        Logger.logger.exception("Error")
        raise e
