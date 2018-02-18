#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""

Code for my master thesis.

Still under development.

@author: João Dimas (joaohenriqueavila@gmail.com)

"""
import math
class Parameters:

    @classmethod
    def init(cls):

        """

        Parameters common to all scenarios and experiments.

        """

        Parameters.Periods = 300 # 800
        Parameters.NumberOfHouseholds = 500 # 500

        Parameters.InnelasticLabourSupply = 1 # 1
        Parameters.TechnologyFactor = 1 # 1
        Parameters.Alpha = 0.25 # 0.25
        Parameters.Mu = 0.1 # 0.1
        Parameters.Epsilon = 0.01 # 0.01
        Parameters.MaxConsumptionShare = 1.5 # 1.5
        Parameters.MinConsumptionShare = 0.5 # 0.5
        Parameters.NaturalInterestRate = 0 # 0
        Parameters.NaturalUnemploymentRate = 0 # 0
        Parameters.InflationTarget = 0.02 # 0.02
        Parameters.InterestLowerBound = 0
        
        # Households individual behavior
        Parameters.setLearningLevel(1)
        Parameters.Ro = 0.45
        Parameters.SubstitutionStrategySD = 0.30
        Parameters.IndexationStrategySD = 0.30
        
        # Expectations
        Parameters.AllHouseholdsSameExpectation = False # Coordination
        Parameters.NoiseInflationTargetPerceptionSD = 0.02 # Noise in the communication of inflation target by the CB
        Parameters.Chi = 0.7 # Credibility of the central bank
        
        # Monetary policy parameters
        Parameters.Phi_inflation = 1.2
        Parameters.Phi_unemployment = 0.2
        
        # Windows of observation
        Parameters.ProfitWindowOfObservation = (int) (-3 * math.log(10) / math.log(Parameters.Ro))
        Parameters.UtilityWindowOfObservation = (int) (-3 * math.log(10) / math.log(Parameters.Ro))
        Parameters.InflationWindowOfObservation = (int) (-3 * math.log(10) / math.log(Parameters.Ro))
        Parameters.IncomeWindowOfObservation = (int) (-3 * math.log(10) / math.log(Parameters.Ro))

        # Initial values: The paper doesn't explicit these initial values, therefore we are assuming them.
        Parameters.InitialPriceLevel = 10
        Parameters.InitialLabourDemand = 0.9 * Parameters.NumberOfHouseholds
        Parameters.InitialMeanIndexationStrategy = 1
        Parameters.InitialMeanSubstitutionStrategy = 1
        Parameters.InitialReservationWageRange = [1, 50]
        Parameters.InitialSavingsBalance = 0
        
        # Maximum number for which Python keeps the mathematical precision. After that, abort the simulation.
        Parameters.MaximumPrecision = 1e100
        
        

    @classmethod
    def setLearningLevel(cls, level):
        Parameters.LearningLevel = level
        if level == 0:
            # Learning level 0
            Parameters.ProbImitation = 0.05
            Parameters.ProbMutation = 0.01
        elif level == 1:
            # Learning level 1
            Parameters.ProbImitation = 0.1
            Parameters.ProbMutation = 0.05
        elif level == 2:
            # Learning level 2
            Parameters.ProbImitation = 0.15
            Parameters.ProbMutation = 0.1
        elif level == None:
            Parameters.ProbImitation = 0
            Parameters.ProbMutation = 0