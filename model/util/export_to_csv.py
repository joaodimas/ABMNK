"""
Project for course Quantitative Methods in Finance, Prof. Eric Vansteenberghe.
Université Paris 1 Panthéon-Sorbonne
Program: Master 2 Financial Economics, 2017.
Authors: João Dimas (joaohenriqueavila@gmail.com) and Umberto Collodel (umberto.collodel@gmail.com)

Replication of an agent-based model described in:
Salle, I., Yıldızoğlu, M., & Sénégas, M.-A. (2013). Inflation targeting in a learning economy: An ABM perspective. Economic Modelling, 34, 114–128.

Technical information on README.md

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
