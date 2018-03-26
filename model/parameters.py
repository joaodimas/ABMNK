#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""

Code for my master thesis.

Still under development.

@author: João Dimas (joaohenriqueavila@gmail.com)

"""
import math
class Parameters:

    def __init__(self, scenario, experiment):

        self.Scenario = scenario
        self.Experiment = experiment
        """

        Parameters common to all scenarios and experiments.

        """
        self.Periods = 800 # 800
        self.NumberOfHouseholds = 500 # 500

        self.InnelasticLabourSupply = 1 # 1
        self.TechnologyFactor = 1 # 1
        self.Alpha = 0.25 # 0.25
        self.Mu = 0.1 # 0.1
        self.Epsilon = 0.01 # 0.01
        self.MaxConsumptionShare = 1.5 # 1.5
        self.MinConsumptionShare = 0.5 # 0.5
        self.NaturalInterestRate = 0 # 0
        self.NaturalUnemploymentRate = 0 # 0
        self.InflationTarget = 0.02 # 0.02
        self.InterestLowerBound = -0.005
        
        # Households individual behavior
#        self.setLearningLevel(1)
#        self.Ro = 0.45
#        self.Sigma_mutK = 0.30
#        self.Sigma_mutW = 0.30
        
        # Expectations
#        self.HouseholdCoordination = False # Coordination
#        self.Sigma_xi = 0.02 # Noise in the communication of inflation target by the CB
#        self.Chi = 0.7 # Credibility of the central bank
#        
#        # Monetary policy params
#        self.Phi_inflation = 1.2
#        self.Phi_unemployment = 0.2
        
        getattr(self, "setExperiment{:d}".format(experiment))()
        getattr(self, "setScenario{:d}".format(scenario))()
        
        # Windows of observation (implies that Ro^(t-l) up to 0.00005 is relevant)
        self.ProfitWindowOfObservation = (int) (-5 * math.log(10) / math.log(self.Ro)) if self.Ro > 0 else 2
        self.UtilityWindowOfObservation = (int) (-5 * math.log(10) / math.log(self.Ro)) if self.Ro > 0 else 2
        self.InflationWindowOfObservation = (int) (-5 * math.log(10) / math.log(self.Ro)) if self.Ro > 0 else 2
        self.IncomeWindowOfObservation = (int) (-5 * math.log(10) / math.log(self.Ro)) if self.Ro > 0 else 2

        # Initial values: The paper doesn't explicit these initial values, therefore we are assuming them.
        self.InitialPriceLevel = 1e-300
        self.InitialLabourDemand = 0.1 * self.NumberOfHouseholds
        self.InitialMeanIndexationStrategy = 0.2
        self.InitialMeanSubstitutionStrategy = 0.2
        self.InitialReservationWageRange = [1, 50]
        self.InitialSavingsBalance = 0
        
        # Maximum number for which Python keeps the mathematical precision. After that, abort the simulation.
        self.MaximumPrecision = 1e1000
        
        
    def setLearningLevel(self, level):
        self.LearningLevel = level
        if level == 0:
            # Learning level 0
            self.ProbImitation = 0.05
            self.ProbMutation = 0.01
        elif level == 1:
            # Learning level 1
            self.ProbImitation = 0.1
            self.ProbMutation = 0.05
        elif level == 2:
            # Learning level 2
            self.ProbImitation = 0.15
            self.ProbMutation = 0.1
        elif level == None:
            self.ProbImitation = 0
            self.ProbMutation = 0
            
    def setScenario1(self):
        self.HouseholdCoordination = True # Coordination
        self.Sigma_xi = 0 # Perfect precision
        self.Chi = 1 # Perfect credibility
        
    def setScenario2(self):
        self.HouseholdCoordination = True # Coordination
        self.Chi = 1 # Perfect credibility        
        
    def setScenario3(self):
        self.HouseholdCoordination = False # Coordination
        self.Chi = 1 # Perfect credibility        

    def setScenario4(self):
        self.HouseholdCoordination = True # Coordination
        self.Sigma_xi = 0 # Perfect precision        

    def setScenario5(self):
        self.HouseholdCoordination = True # Coordination
        self.Sigma_xi = 0 # Perfect precision
        self.Chi = 0 # No credibility    

    
    def setExperiment1(self):
        self.setLearningLevel(1)
        self.Ro = 0.9
        self.Sigma_mutK = 0.33
        self.Sigma_mutW = 0.18
        self.Phi_inflation = 0.5
        self.Phi_unemployment = 0.9
        self.Sigma_xi = 0.029 # Noise in the communication of inflation target by the CB
        self.Chi = 0.6
    
    def setExperiment2(self):
        self.setLearningLevel(0)
        self.Ro = 0.45
        self.Sigma_mutK = 0.36
        self.Sigma_mutW = 0.25
        self.Phi_inflation = 0
        self.Phi_unemployment = 0.3
        self.Sigma_xi = 0.032 # Noise in the communication of inflation target by the CB
        self.Chi = 0.6        

    
    def setExperiment3(self):
        self.setLearningLevel(0)
        self.Ro = 0.45
        self.Sigma_mutK = 0.07
        self.Sigma_mutW = 0.14
        self.Phi_inflation = 1.3
        self.Phi_unemployment = 0.8
        self.Sigma_xi = 0.05 # Noise in the communication of inflation target by the CB
        self.Chi = 0.9

    
    def setExperiment4(self):
        self.setLearningLevel(0)
        self.Ro = 0.45
        self.Sigma_mutK = 0.16
        self.Sigma_mutW = 0.4
        self.Phi_inflation = 1.1
        self.Phi_unemployment = 0.1
        self.Sigma_xi = 0.038 # Noise in the communication of inflation target by the CB
        self.Chi = 0.7

    
    def setExperiment5(self):
        self.setLearningLevel(2)
        self.Ro = 0.9
        self.Sigma_mutK = 0.2
        self.Sigma_mutW = 0.09
        self.Phi_inflation = 0.6
        self.Phi_unemployment = 0
        self.Sigma_xi = 0.041 # Noise in the communication of inflation target by the CB
        self.Chi = 0.8

    
    def setExperiment6(self):
        self.setLearningLevel(2)
        self.Ro = 0.45
        self.Sigma_mutK = 0.18
        self.Sigma_mutW = 0.33
        self.Phi_inflation = 0.1
        self.Phi_unemployment = 0.8
        self.Sigma_xi = 0.044 # Noise in the communication of inflation target by the CB
        self.Chi = 0.8

    
    def setExperiment7(self):
        self.setLearningLevel(1)
        self.Ro = 0
        self.Sigma_mutK = 0.4
        self.Sigma_mutW = 0.16
        self.Phi_inflation = 1.8
        self.Phi_unemployment = 0.4
        self.Sigma_xi = 0.047 # Noise in the communication of inflation target by the CB
        self.Chi = 0.9
    
    def setExperiment8(self):
        self.setLearningLevel(1)
        self.Ro = 0.9
        self.Sigma_mutK = 0.31
        self.Sigma_mutW = 0.38
        self.Phi_inflation = 1.6
        self.Phi_unemployment = 0.6
        self.Sigma_xi = 0.035 # Noise in the communication of inflation target by the CB
        self.Chi = 0.7
    
    def setExperiment9(self):
        self.setLearningLevel(1)
        self.Ro = 0.45
        self.Sigma_mutK = 0.23
        self.Sigma_mutW = 0.23
        self.Phi_inflation = 1
        self.Phi_unemployment = 0.5
        self.Sigma_xi = 0.026 # Noise in the communication of inflation target by the CB
        self.Chi = 0.5
    
    def setExperiment10(self):
        self.setLearningLevel(1)
        self.Ro = 0
        self.Sigma_mutK = 0.12
        self.Sigma_mutW = 0.27
        self.Phi_inflation = 1.5
        self.Phi_unemployment = 0.1
        self.Sigma_xi = 0.022 # Noise in the communication of inflation target by the CB
        self.Chi = 0.5
    
    def setExperiment11(self):
        self.setLearningLevel(2)
        self.Ro = 0.9
        self.Sigma_mutK = 0.09
        self.Sigma_mutW = 0.2
        self.Phi_inflation = 2
        self.Phi_unemployment = 0.7
        self.Sigma_xi = 0.019 # Noise in the communication of inflation target by the CB
        self.Chi = 0.4
    
    def setExperiment12(self):
        self.setLearningLevel(2)
        self.Ro = 0.45
        self.Sigma_mutK = 0.38
        self.Sigma_mutW = 0.31
        self.Phi_inflation = 0.8
        self.Phi_unemployment = 0.2
        self.Sigma_xi = 0.001 # Noise in the communication of inflation target by the CB
        self.Chi = 0.1
    
    def setExperiment13(self):
        self.setLearningLevel(2)
        self.Ro = 0.45
        self.Sigma_mutK = 0.29
        self.Sigma_mutW = 0.05
        self.Phi_inflation = 0.9
        self.Phi_unemployment = 0.9
        self.Sigma_xi = 0.013 # Noise in the communication of inflation target by the CB
        self.Chi = 0.3
    
    def setExperiment14(self):
        self.setLearningLevel(1)
        self.Ro = 0
        self.Sigma_mutK = 0.25
        self.Sigma_mutW = 0.36
        self.Phi_inflation = 1.4
        self.Phi_unemployment = 1
        self.Sigma_xi = 0.01 # Noise in the communication of inflation target by the CB
        self.Chi = 0.3
    
    def setExperiment15(self):
        self.setLearningLevel(0)
        self.Ro = 0.45
        self.Sigma_mutK = 0.27
        self.Sigma_mutW = 0.12
        self.Phi_inflation = 1.9
        self.Phi_unemployment = 0.3
        self.Sigma_xi = 0.007 # Noise in the communication of inflation target by the CB
        self.Chi = 0.2
    
    def setExperiment16(self):
        self.setLearningLevel(1)
        self.Ro = 0.9
        self.Sigma_mutK = 0.05
        self.Sigma_mutW = 0.29
        self.Phi_inflation = 0.3
        self.Phi_unemployment = 0.6
        self.Sigma_xi = 0.004 # Noise in the communication of inflation target by the CB
        self.Chi = 0.2
    
    def setExperiment17(self):
        self.setLearningLevel(1)
        self.Ro = 0
        self.Sigma_mutK = 0.14
        self.Sigma_mutW = 0.07
        self.Phi_inflation = 0.4
        self.Phi_unemployment = 0.4
        self.Sigma_xi = 0.016 # Noise in the communication of inflation target by the CB
        self.Chi = 0.4