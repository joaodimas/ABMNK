"""

Code for my master thesis.

Still under development.

@author: João Dimas (joaohenriqueavila@gmail.com)

"""

import csv, os

class ExportToCSV:

    @classmethod
    def exportAggregateStatistics(cls, data, timestamp, scenario):

        if data is None:
            return

        suffix = "AggregateStatistics"

        cls.writeFile(data, suffix, timestamp, scenario)


    @classmethod
    def exportGranularData(cls, data, timestamp, scenario, experiment, simulationNumber):

        if data is None:
            return

        suffix = "[Exp_{:d}][Sim_{:d}]GranularData".format(experiment, simulationNumber)

        cls.writeFile(data, suffix, timestamp, scenario)

    @classmethod
    def writeFile(cls, flatData, suffix, timestamp, scenario):
        THIS_FOLDER = os.path.dirname(os.path.abspath(__file__))
        with open(os.path.join(THIS_FOLDER, "../../data/ABMNK.{}[Sce_{:d}]{}.csv".format(timestamp.strftime("%Y-%m-%dT%Hh%Mm%Ss"), scenario, suffix)), "w", newline='') as f:
            writer = csv.writer(f, dialect='excel')
            writer.writerows(flatData)
            
        with open(os.path.join(THIS_FOLDER, "../../data/ABMNK.LAST[Sce_{:d}]{}.csv".format(scenario, suffix)), "w", newline='') as f:
            writer = csv.writer(f, dialect='excel')
            writer.writerows(flatData)            
