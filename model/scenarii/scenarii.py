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

import importlib, inspect

"""

This class will dinamically load the chosen scenario.

"""
class Scenarii:

    @classmethod
    def setExperiment(cls, scenario, experiment):

        # Loading module
        module = importlib.import_module("model.scenarii.scenario{:d}".format(scenario, scenario))

        # Finding class
        member = [m[1] for m in inspect.getmembers(module) if m[0] == "Scenario{:d}".format(scenario)][0]

        # Calling setExperiment from the chosen scenario
        getattr(member, 'setExperiment')(experiment)
