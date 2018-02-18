"""

Code for my master thesis.

Still under development.

@author: João Dimas (joaohenriqueavila@gmail.com)

"""

import csv, os

class ExportToCSV:

    @classmethod
    def exportAggregateStatistics(cls, data, timestamp):

        if data is None:
            return

        suffix = "AggregateStatistics"

        cls.writeFile(data, suffix, timestamp)


    @classmethod
    def exportGranularData(cls, data, timestamp):

        if data is None:
            return

        suffix = "GranularData"

        cls.writeFile(data, suffix, timestamp)

    @classmethod
    def writeFile(cls, flatData, suffix, timestamp):
        THIS_FOLDER = os.path.dirname(os.path.abspath(__file__))
        with open(os.path.join(THIS_FOLDER, "../../data/ABMNK.{}.{}.csv".format(timestamp.strftime("%Y-%m-%dT%Hh%Mm%Ss"), suffix)), "w", newline='') as f:
            writer = csv.writer(f, dialect='excel')
            writer.writerows(flatData)
            
        with open(os.path.join(THIS_FOLDER, "../../data/ABMNK.LAST.{}.csv".format(suffix)), "w", newline='') as f:
            writer = csv.writer(f, dialect='excel')
            writer.writerows(flatData)            
