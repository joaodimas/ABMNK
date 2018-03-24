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
        self.LogLevel = {"Console": ["INFO"], "File":["INFO"]} # Set INFO, DEBUG or TRACE for Console and File.
    
        self.SimulationsPerExperiment = 20 # Number of independent executions.
        self.Scenarii = [1,2,3,4,5]
        self.Experiments = range(1,18)
    
        self.PauseInterval = None
    
def saveModelParameters(timestamp, logger, parameters):
    parametersList = {}
    members = [attr for attr in dir(parameters) if not callable(getattr(parameters, attr)) and not attr.startswith("__")]
    for member in members:
        parametersList[member] = getattr(parameters, member)

    desc = ""
    for key, value in parametersList.items():
        desc += key + ": " + str(value) + "\n"

    logger.info(parametersList)
    THIS_FOLDER = os.path.dirname(os.path.abspath(__file__))
    with open(os.path.join(THIS_FOLDER, ("./data/ABMNK.{}[Sce_{:d}][Exp_{:d}].parameters.txt").format(timestamp.strftime("%Y-%m-%dT%Hh%Mm%Ss"), parameters.Scenario, parameters.Experiment)), "w", newline='') as f:
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

def simulate(item, systemConfig, scenario):
    try:
        granularResults = []
        experiment = int((item-1)/systemConfig.SimulationsPerExperiment)+1
        simulationNumber = item % systemConfig.SimulationsPerExperiment
        if simulationNumber == 0:
            simulationNumber = systemConfig.SimulationsPerExperiment
            
        logger = Logger(timestamp, systemConfig.LogLevel, scenario, experiment)
        parameters = Parameters(scenario, experiment)
    
        # Saving parameters to file.
        saveModelParameters(timestamp, logger, parameters)
    
        runStartTime = time.time()
    
        logger.info("Starting scenario {:d}, experiment {:d}, simulation {:d}.".format(scenario, experiment, simulationNumber))
    
        # Create a virtual economy with heterogeneous agents
        economy = Economy(logger, parameters, simulationNumber)
        for t in range(1,parameters.Periods+1):
            checkPause(systemConfig, economy, t)
            economy.runCurrentPeriod()
            granularResults.append(ResultsData.getCurrentPeriodData(economy))
            economy.describeCurrentPeriod()
            economy.nextPeriod()
    
        logger.info("Simulation completed in {:.2f} seconds.", ((time.time() - runStartTime), scenario), economy=economy)
        
        ExportToCSV.exportGranularData(granularResults, timestamp, scenario, experiment, simulationNumber)
        
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
            granularResults = []
    
            processes = []
            
            if systemConfig.SimulationsPerExperiment > 1 or len(systemConfig.Experiments)>1:
                # Start a parallel process for each CPU
                pool = multiprocessing.Pool(multiprocessing.cpu_count())
                
                partial_simulate = functools.partial(simulate, systemConfig=systemConfig, scenario=scenario)
                # Run function simulate in parallel for each independent execution and aggregate results.
                listOfResults = pool.imap_unordered(partial_simulate, range(1,len(systemConfig.Experiments)*systemConfig.SimulationsPerExperiment+1)) 
                # Append results
                for result in listOfResults:
                    if len(result) > 0:
                        granularResults = granularResults + result
            else:
                granularResults = simulate(1, systemConfig, scenario)
    
            # Sort results by Run, Period. Then, add header.
            granularResults = [ResultsData.getHeader()] + sorted(granularResults, key=operator.itemgetter(0,1))
    
            if len(granularResults) > 2:
                aggregateStatistics = ResultsData.getAggregateStatistics(granularResults)
                ExportToCSV.exportAggregateStatistics(aggregateStatistics, timestamp, scenario)

    except Exception as e:
        print(e)
        raise e
