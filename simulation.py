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
import datetime, os, time, multiprocessing, operator, functools

class SystemConfig:
    def __init__(self):
        self.LogLevel = {"Console": ["DEBUG"], "File":["DEBUG"]} # Set INFO, DEBUG or TRACE for Console and File.
    
        self.NumberOfSimulations = 1 # Number of independent executions.
        self.PauseInterval = None
        self.Scenarii = [4,5]
        self.Experiments = range(1,18)
    
    
def saveModelParameters(timestamp, parameters):
    parametersList = {}
    members = [attr for attr in dir(parameters) if not callable(getattr(parameters, attr)) and not attr.startswith("__")]
    for member in members:
        parametersList[member] = getattr(parameters, member)

    desc = ""
    for key, value in parametersList.items():
        desc += key + ": " + str(value) + "\n"

    logger.info(parametersList)
    THIS_FOLDER = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(THIS_FOLDER, ("./data/ABMNK.{}[Sce_{:d}][Exp_{:d}].parameters.txt").format(timestamp.strftime("%Y-%m-%dT%Hh%Mm%Ss"), scenario, experiment)), "w", newline='') as f:
        print(parametersList, file=f)

def checkPause(systemConfig, economy, t):
    if systemConfig.PauseInterval is not None and t % systemConfig.PauseInterval == 0:
        command = None
        while command != "":
            try:
                command = input("God mode: ")
                if command != "":
                    if command.isdigit():
                        systemConfig.PauseInterval = int(command)
                        print("New pause interval: {:d}".format(systemConfig.PauseInterval))
                    elif "=" in command or "(" in command: 
                        if hasattr(economy, command.split(" =")[0]) or hasattr(economy, command.split("=")[0]) or hasattr(economy, command.split("(")[0]) or hasattr(economy, command.split(".")[0]):
                            exec("economy." + command)
                        else:
                            exec(command)
                    elif hasattr(economy.parameters, command):
                        print(eval("economy.parameters." + command))
                    elif hasattr(economy, command) or hasattr(economy, command.split(".")[0]):
                        print(eval("economy."+ command))
                    else:
                        print(eval(command))
            except Exception as ex:
                print(ex)

def simulate(simulationNumber, logger, systemConfig, parameters):
    try:
        granularResults = []
        runStartTime = time.time()

        logger.info("Starting run {:d}.".format(simulationNumber))

        # Create a virtual economy with heterogeneous agents
        economy = Economy(logger, parameters, simulationNumber)
        for t in range(1,parameters.Periods+1):
            
            checkPause(systemConfig, economy, t)
            logger.info("[SCE {:02d}][EXP {:02d}][RUN {:03d}][PERIOD {:03d}] Simulating...".format(parameters.Scenario, parameters.Experiment, simulationNumber, t))            
            economy.runCurrentPeriod()
            granularResults.append(ResultsData.getCurrentPeriodData(economy))
            economy.describeCurrentPeriod()
            economy.nextPeriod()

        logger.info("Simulation completed in {:.2f} seconds. Simulation number: {:d}.", ((time.time() - runStartTime), simulationNumber))
        return granularResults
    except ValueError as e:
        logger.exception(e)
        raise e
    except Exception as e:
        logger.exception("Error")
        raise e

# MAIN EXECUTION THREAD
if __name__ == '__main__':

    try:
        timestamp = datetime.datetime.now()
        aggregateStartTime = time.time()
        systemConfig = SystemConfig()
        for scenario in systemConfig.Scenarii:
            for experiment in systemConfig.Experiments:
                granularResults = []
                logger = Logger(timestamp, scenario, experiment, systemConfig.LogLevel)
                parameters = Parameters(scenario, experiment)
        
                # Saving parameters to file.
                saveModelParameters(timestamp, parameters)
        
                processes = []
                
                if systemConfig.NumberOfSimulations > 1:
                    # Start a parallel process for each CPU
                    pool = multiprocessing.Pool(multiprocessing.cpu_count())
                    
                    partial_simulate = functools.partial(simulate, logger=logger, systemConfig=systemConfig, parameters=parameters)
                    # Run function simulate in parallel for each independent execution and aggregate results.
                    listOfResults = pool.imap_unordered(partial_simulate, range(1,systemConfig.NumberOfSimulations+1)) 
                    # Append results
                    for result in listOfResults:
                        if len(result) > 0:
                            granularResults = granularResults + result
                else:
                    granularResults = simulate(1, logger, systemConfig, parameters)
        
                # Sort results by Run, Period. Then, add header.
                granularResults = [ResultsData.getHeader()] + sorted(granularResults, key=operator.itemgetter(0,1))
        
                logger.info("All replications completed. Total time {:.2f} seconds.", time.time() - aggregateStartTime)
                logger.info("Saving granular data...")
                ExportToCSV.exportGranularData(granularResults, timestamp, scenario, experiment)
        
                if len(granularResults) > 2:
                    logger.info("Saving aggregate statistics...")
                    aggregateStatistics = ResultsData.getAggregateStatistics(granularResults)
                    ExportToCSV.exportAggregateStatistics(aggregateStatistics, timestamp, scenario, experiment)

        logger.info("ALL PROCESSES FINISHED!")
    except Exception as e:
        logger.exception("Error")
        raise e
