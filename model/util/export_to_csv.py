"""

Code for my master thesis.

Still under development.

@author: João Dimas (joaohenriqueavila@gmail.com)

"""

import csv, os

class ExportToCSV:

    @classmethod
    def exportAggregateStatistics(cls, data, timestamp, scenario, experiment):

        if data is None:
            return

        suffix = "AggregateStatistics"

        cls.writeFile(data, suffix, timestamp, scenario, experiment)


    @classmethod
    def exportGranularData(cls, data, timestamp, scenario, experiment):

        if data is None:
            return

        suffix = "GranularData"

        cls.writeFile(data, suffix, timestamp, scenario, experiment)

    @classmethod
    def writeFile(cls, flatData, suffix, timestamp, scenario, experiment):
        THIS_FOLDER = os.path.dirname(os.path.abspath(__file__))
        with open(os.path.join(THIS_FOLDER, "../../data/ABMNK.{}[Sce_{:d}][Exp_{:d}].{}.csv".format(timestamp.strftime("%Y-%m-%dT%Hh%Mm%Ss"), scenario, experiment, suffix)), "w", newline='') as f:
            writer = csv.writer(f, dialect='excel')
            writer.writerows(flatData)
            
        with open(os.path.join(THIS_FOLDER, "../../data/ABMNK.LAST[Sce_{:d}][Exp_{:d}].{}.csv".format(scenario, experiment, suffix)), "w", newline='') as f:
            writer = csv.writer(f, dialect='excel')
            writer.writerows(flatData)            
