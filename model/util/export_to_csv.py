"""
Project for course Quantitative Methods in Finance, Prof. Eric Vansteenberghe.
Université Paris 1 Panthéon-Sorbonne
Program: Master 2 Financial Economics, 2017.
Authors: João Dimas (joaohenriqueavila@gmail.com) and Umberto Collodel (umberto.collodel@gmail.com)

Replication of an agent-based model described in:
Salle, I., Yıldızoğlu, M., & Sénégas, M.-A. (2013). Inflation targeting in a learning economy: An ABM perspective. Economic Modelling, 34, 114–128.
"""

import csv, os

class ExportToCSV:

    @classmethod
    def exportTimeSeriesData(cls, data, timestamp, simulation = None):

        if data is None:
            return

        suffix = "[{:d}]".format(simulation) if simulation != None else "[MEAN]"

        cls.writeFile(data, suffix, timestamp)

    @classmethod
    def writeFile(cls, flatData, suffix, timestamp):
        THIS_FOLDER = os.path.dirname(os.path.abspath(__file__))
        with open(os.path.join(THIS_FOLDER, "../../data/ABMNK."+timestamp.strftime("%Y-%m-%dT%Hh%Mm%Ss")+suffix+".csv"), "w", newline='') as f:
            writer = csv.writer(f, dialect='excel')
            writer.writerows(flatData)

        with open(os.path.join(THIS_FOLDER, "../../data/ABMNK.[LATEST]"+suffix+".csv"), "w", newline='') as f:
            writer = csv.writer(f, dialect='excel')
            writer.writerows(flatData)
    