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

class Parameters:

    @classmethod
    def init(cls):
        # Parameters
        cls.Periods = 200
        cls.NumberOfHouseholds = 100
        cls.Ro = 0 # [0,1[
        cls.InitialPriceLevel = 1
        cls.InnelasticLabourSupply = 1



        cls.IndexationStrategySD = 0.05
        cls.SubstitutionStrategySD = 0.05
        # Slow learning
        cls.ProbImitation = 0.05
        cls.ProbMutation = 0.01
        # Active learning 1
        cls.ProbImitation = 0.1
        cls.ProbMutation = 0.05
        # Active learning 2
        cls.ProbImitation = 0.15
        cls.ProbMutation = 0.1

        cls.TechnologyFactor = 1
        cls.Alpha = 0.2 # [0,1[
        cls.Mu = 0.1 # Markup
        cls.Epsilon = 0.01 # >0
        cls.MaxConsumptionShare = 1.5
        cls.MinConsumptionShare = 0.5
        cls.NaturalInterestRate = 0
        cls.NaturalUnemploymentRate = 0
        cls.InflationTarget = 0.02
        cls.Phi_inflation = 1
        cls.Phi_unemployment = 0.5
        cls.Chi = 0.1
        cls.NoiseInflationTargetPerceptionSD = 0.02
        cls.AllHouseholdsSameExpectation = False

        # TODO: Initial values: The paper doesn't explicit these initial values, therefore we are assuming some values that make the model work.
        cls.InitialLabourDemand = 10 # We need a high initial labour demand so all households have positive income. Otherwise, some will not consume and will have negative infinite utility (u=log(c)).
        cls.InitialMeanIndexationStrategy = 1
        cls.InitialMeanSubstitutionStrategy = 0.5
        cls.InitialReservationWageRange = [10, 20] # We need this initial heterogeneity so the price is not higher than all wages at period 0. This way, some households will be able to consume.