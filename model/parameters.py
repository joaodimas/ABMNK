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
        cls.NumberOfHouseholds = 1 # 500

        cls.InnelasticLabourSupply = 1 # 1
        cls.TechnologyFactor = 1 # 1
        cls.Alpha = 0.25 # 0.25
        cls.Mu = 0.1 # 0.1
        cls.Epsilon = 0.01 # 0.01
        cls.MaxConsumptionShare = 1.5 # 1.5
        cls.MinConsumptionShare = 0.1 # 0.5
        cls.NaturalInterestRate = 0 # 0
        cls.NaturalUnemploymentRate = 0 # 0
        cls.InflationTarget = 0.02 # 0.02
        
        # Households individual behavior
        Parameters.setLearningLevel(None)
        Parameters.Ro = 0.45
        Parameters.SubstitutionStrategySD = 0.30
        Parameters.IndexationStrategySD = 0.30
        
        # Expectations
        Parameters.AllHouseholdsSameExpectation = False # Coordination
        Parameters.NoiseInflationTargetPerceptionSD = 0.5 # Noise in the communication of inflation target by the CB
        Parameters.Chi = 1 # Credibility of the central bank
        
        # Monetary policy parameters
        Parameters.Phi_inflation = 0.5
        Parameters.Phi_unemployment = 5
        
        # Windows of observation
        Parameters.FirmWindowOfObservation = 20
        Parameters.HouseholdsUtilityWindowOfObservation = 20
        Parameters.InflationWindowOfObservation = 800

        # Initial values: The paper doesn't explicit these initial values, therefore we are assuming them.
        cls.InitialPriceLevel = 1
        cls.InitialLabourDemand = 1
        cls.InitialMeanIndexationStrategy = 1
        cls.InitialMeanSubstitutionStrategy = 5
        cls.InitialReservationWageRange = [1, 1]
        cls.InitialSavingsBalance = 0
        
        # Maximum price for which Python keeps the mathematical precision. After that, abort the simulation.
        cls.MaximumPricePrecision = 1e40
        
        

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
        elif level == None:
            cls.ProbImitation = 0
            cls.ProbMutation = 0