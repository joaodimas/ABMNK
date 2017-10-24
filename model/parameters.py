#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Oct 24 16:44:01 2017

@author: jdimas
"""

class Parameters:

    @classmethod
    def setInitialParameters(cls):
        # Parameters
        cls.NmbHouseholds = 10
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
               