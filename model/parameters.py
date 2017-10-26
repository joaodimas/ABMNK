#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Oct 24 16:44:01 2017

@author: João Dimas and Umberto Collodel
"""

class Parameters:

    @classmethod
    def init(cls):
        # Parameters
        cls.Periods = 100
        cls.NumberOfHouseholds = 10
        cls.Ro = 0.5 # [0,1[
        cls.InitialPriceLevel = 1
        cls.InnelasticLabourSupply = 1
        cls.IndexationStrategySD = 1
        cls.SubstitutionStrategySD = 1
        cls.ProbImitation = 0.05
        cls.ProbMutation = 0.01
        cls.TechnologyFactor = 1
        cls.Alpha = 0.1 # [0,1[
        cls.Markup = 0.5
        cls.Epsilon = 0.1 # >0
        cls.NaturalInterestRate = 0
        cls.NaturalUnemploymentRate = 0
        cls.InflationTarget = 0
        cls.Phi_inflation = 0
        cls.Phi_unemployment = 0
        cls.Chi = 0.1
        cls.NoiseInflationTargetPerceptionSD = 0
        cls.AllHouseholdsSameExpectation = False