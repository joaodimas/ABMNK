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
from model.resultsdata import ResultsData
from model.util.export_to_csv import ExportToCSV
from model.util.logger import Logger
from model.scenarii.scenarii import Scenarii
import datetime, cProfile, io, pstats, os, time

class SystemConfig:
    LogLevel = {"Console": ["INFO"], "File":["INFO"]}
    EnableProfilingMainThread = False
    Scenario = 1
    ExperimentsPerScenario = 17
    RunsPerExperiment = 20

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

#for hh in economy.households:
#    print(hh.householdId)
#    print(hh.getReservationWage())
#    print(hh.effectivelySuppliedLabour)

if __name__ == '__main__':

    pr = None
    if(SystemConfig.EnableProfilingMainThread):
        pr = cProfile.Profile()
        pr.enable()

    try:
        generalTimestamp = datetime.datetime.now()
        granularResults = [ResultsData.getHeader()]
        aggregateStartTime = time.time()
        Logger.initialize(generalTimestamp, SystemConfig.LogLevel, SystemConfig.Scenario)
        for experiment in range(1, SystemConfig.ExperimentsPerScenario+1):
            Parameters.init()
            Scenarii.setExperiment(SystemConfig.Scenario, experiment)
            parameters = describeModelParameters()
            Logger.info(parameters)
            THIS_FOLDER = os.path.dirname(os.path.abspath(__file__))
            with open(os.path.join(THIS_FOLDER, ("./data/ABMNK.Scenario{:d}.Experiment{:d}."+generalTimestamp.strftime("%Y-%m-%dT%Hh%Mm%Ss")+".params.txt").format(SystemConfig.Scenario, experiment)), "w", newline='') as f:
                print(parameters, file=f)

            for run in range(1, SystemConfig.RunsPerExperiment+1):
                runStartTime = time.time()

                Logger.info("Starting run {:d}. Scenario {:d}. Experiment {:d}".format(run, SystemConfig.Scenario, experiment))

                # Create a virtual economy with agents
                simulationStartTime = time.time()
                economy = Economy(SystemConfig.Scenario, experiment, run)
                for t in range(Parameters.Periods):
                    economy.runCurrentPeriod()
                    if t >= 99 and t % 50 == 0: # Ignore the first 100 executions and collect data every 50 periods afterwards.
                        granularResults.append(ResultsData.getCurrentPeriodData(economy))
                    economy.describeCurrentPeriod()
                    economy.nextPeriod()

                Logger.info("Simulation completed in {:.2f} seconds. Scenario {:d}. Experiment {:d}. Run {:d}.", ((time.time() - runStartTime), SystemConfig.Scenario, experiment, run))


        Logger.info("All simulations completed. Total time {:.2f} seconds.", time.time() - aggregateStartTime)
        Logger.info("Saving granular data...")
        ExportToCSV.exportTimeSeriesData(granularResults, SystemConfig.Scenario, generalTimestamp)
        Logger.info("Saving aggregate statistics...")
        aggregateStatistics = ResultsData.getAggregateStatistics(granularResults, SystemConfig.Scenario)
        ExportToCSV.exportAggregateStatistics(aggregateStatistics, SystemConfig.Scenario, generalTimestamp)
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