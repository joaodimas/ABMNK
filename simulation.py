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
from model.economy import Economy
from model.parameters import Parameters
from model.resultsdata import ResultsData
from model.util.export_to_csv import ExportToCSV
from model.util.logger import Logger
import datetime, os, time, multiprocessing, operator

class SystemConfig:
    LogLevel = {"Console": ["DEBUG"], "File":["DEBUG"]} # Set INFO, DEBUG or TRACE for Console and File.

    NumberOfSimulations = 5 # Number of independent executions.

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

def simulate(simulationNumber):
    try:
        granularResults = []
        runStartTime = time.time()

        Logger.info("Starting run {:d}.".format(simulationNumber))

        # Create a virtual economy with heterogeneous agents
        economy = Economy(simulationNumber)
        for t in range(1,Parameters.Periods+1):
            economy.runCurrentPeriod()
            if t % 10 == 0: # Ignore the first 99 executions and collect data every 10 periods afterwards.
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
        # Start a parallel process to execute each run.
        pool = multiprocessing.Pool(SystemConfig.NumberOfSimulations)
        # Run function simulate in parallel for each independent execution and aggregate results.
        listOfResults = pool.imap_unordered(simulate, range(1,SystemConfig.NumberOfSimulations+1)) 

        # Append results
        for result in listOfResults:
            if len(result) > 0:
                granularResults = granularResults + result

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
