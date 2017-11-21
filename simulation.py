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
from model.scenarii.scenarii import Scenarii
import datetime, os, time, multiprocessing, functools, operator

class SystemConfig:
    LogLevel = {"Console": ["DEBUG"], "File":["INFO"]} # Set INFO, DEBUG or TRACE for Console and File.

    Scenario = 5 # 1 to 5
    ExperimentsPerScenario = 17 # up to 17. default: 17
    RunsPerExperiment = 20 # default: 20.

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

def simulate(run, experiment):
    try:
        run = run + 1
        granularResults = []
        runStartTime = time.time()

        Logger.info("Starting run {:d}. Scenario {:d}. Experiment {:d}".format(run, SystemConfig.Scenario, experiment))

        # Create a virtual economy with heterogeneous agents
        economy = Economy(SystemConfig.Scenario, experiment, run)
        for t in range(1,Parameters.Periods+1):
            economy.runCurrentPeriod()
            if t >= 100 and t % 50 == 0: # Ignore the first 100 executions and collect data every 50 periods afterwards.
                granularResults.append(ResultsData.getCurrentPeriodData(economy))
            economy.describeCurrentPeriod()
            economy.nextPeriod()

        Logger.info("Simulation completed in {:.2f} seconds. Scenario {:d}. Experiment {:d}. Run {:d}.", ((time.time() - runStartTime), SystemConfig.Scenario, experiment, run))
        return granularResults
    except Exception as e:
        Logger.logger.exception("Error")
        raise e

if __name__ == '__main__':

    try:
        generalTimestamp = datetime.datetime.now()
        granularResults = []
        aggregateStartTime = time.time()
        Logger.initialize(generalTimestamp, SystemConfig.LogLevel, SystemConfig.Scenario)

        # Run each experiment
        for experiment in range(1, SystemConfig.ExperimentsPerScenario+1):
            Parameters.init()
            Scenarii.setExperiment(SystemConfig.Scenario, experiment)

            # Saving parameters to file.
            parameters = describeModelParameters()
            Logger.info(parameters)
            THIS_FOLDER = os.path.dirname(os.path.abspath(__file__))
            with open(os.path.join(THIS_FOLDER, ("./data/ABMNK.{}.Scenario({:d}).Experiment({:d}).params.txt").format(generalTimestamp.strftime("%Y-%m-%dT%Hh%Mm%Ss"), SystemConfig.Scenario, experiment)), "w", newline='') as f:
                print(parameters, file=f)

            processes = []
            pool = multiprocessing.Pool(SystemConfig.RunsPerExperiment)

            # Start a parallel process to execute each run.
            partial_simulate = functools.partial(simulate, experiment=experiment) # Run simulations
            listOfResults = pool.imap_unordered(partial_simulate, range(SystemConfig.RunsPerExperiment)) # Obtain results

            # Append results
            for result in listOfResults:
                granularResults = granularResults + result

        # Sort results by Experiment, Run, Period. Then, add header.
        granularResults = [ResultsData.getHeader()] + sorted(granularResults, key=operator.itemgetter(1,2,3))

        Logger.info("All simulations completed. Total time {:.2f} seconds.", time.time() - aggregateStartTime)
        Logger.info("Saving granular data...")
        ExportToCSV.exportGranularData(granularResults, SystemConfig.Scenario, generalTimestamp)

        if len(granularResults) > 2:
            Logger.info("Saving aggregate statistics...")
            aggregateStatistics = ResultsData.getAggregateStatistics(granularResults, SystemConfig.Scenario)
            ExportToCSV.exportAggregateStatistics(aggregateStatistics, SystemConfig.Scenario, generalTimestamp)

        Logger.info("ALL PROCESSES FINISHED!")
    except Exception as e:
        Logger.logger.exception("Error")
        raise e
