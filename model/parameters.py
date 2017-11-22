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

class Parameters:

    @classmethod
    def init(cls):

        """

        Parameters common to all scenarios and experiments.

        """

        cls.Periods = 800 # 800
        cls.NumberOfHouseholds = 500 # 500

        cls.InnelasticLabourSupply = 1 # 1
        cls.TechnologyFactor = 1 # 1
        cls.Alpha = 0.25 # 0.25
        cls.Mu = 0.1 # 0.1
        cls.Epsilon = 0.01 # 0.01
        cls.MaxConsumptionShare = 1.5 # 1.5
        cls.MinConsumptionShare = 0.5 # 0.5
        cls.NaturalInterestRate = 0 # 0
        cls.NaturalUnemploymentRate = 0 # 0
        cls.InflationTarget = 0.02 # 0.02

        # TODO: Initial values: The paper doesn't explicit these initial values, therefore we are assuming some values that make the model work.
        cls.InitialPriceLevel = 1
        cls.InitialLabourDemand = 400
        cls.InitialMeanIndexationStrategy = 0.3
        cls.InitialMeanSubstitutionStrategy = 0.3
        cls.InitialReservationWageRange = [10, 20]

    @classmethod
    def setLearningLevel(cls, level):
        if level == 0:
            # Learning level 0
            cls.ProbImitation = 0.05
            cls.ProbMutation = 0.01
        elif level == 1:
            # Learning level 1
            cls.ProbImitation = 0.1
            cls.ProbMutation = 0.05
        elif level == 2:
            # Learning level 2
            cls.ProbImitation = 0.15
            cls.ProbMutation = 0.1