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

from model.parameters import Parameters

"""

Sets parameters for Scenario 5.

"""
class Scenario5:

    @classmethod
    def setExperiment(cls, experiment):
        Parameters.AllHouseholdsSameExpectation = True # Coordination
        Parameters.NoiseInflationTargetPerceptionSD = 0 # Perfect precision
        Parameters.Chi = 0

        getattr(cls, 'setExperiment{:d}'.format(experiment))()

    @classmethod
    def setExperiment1(cls):
        Parameters.setLearningLevel(1)
        Parameters.Ro = 0.9
        Parameters.SubstitutionStrategySD = 0.33
        Parameters.IndexationStrategySD = 0.18
        Parameters.Phi_inflation = 0.5
        Parameters.Phi_unemployment = 0.9

    @classmethod
    def setExperiment2(cls):
        Parameters.setLearningLevel(0)
        Parameters.Ro = 0.45
        Parameters.SubstitutionStrategySD = 0.36
        Parameters.IndexationStrategySD = 0.25
        Parameters.Phi_inflation = 0
        Parameters.Phi_unemployment = 0.3

    @classmethod
    def setExperiment3(cls):
        Parameters.setLearningLevel(0)
        Parameters.Ro = 0.45
        Parameters.SubstitutionStrategySD = 0.07
        Parameters.IndexationStrategySD = 0.14
        Parameters.Phi_inflation = 1.3
        Parameters.Phi_unemployment = 0.8

    @classmethod
    def setExperiment4(cls):
        Parameters.setLearningLevel(0)
        Parameters.Ro = 0.45
        Parameters.SubstitutionStrategySD = 0.16
        Parameters.IndexationStrategySD = 0.4
        Parameters.Phi_inflation = 1.1
        Parameters.Phi_unemployment = 0.1

    @classmethod
    def setExperiment5(cls):
        Parameters.setLearningLevel(2)
        Parameters.Ro = 0.9
        Parameters.SubstitutionStrategySD = 0.2
        Parameters.IndexationStrategySD = 0.09
        Parameters.Phi_inflation = 0.6
        Parameters.Phi_unemployment = 0

    @classmethod
    def setExperiment6(cls):
        Parameters.setLearningLevel(2)
        Parameters.Ro = 0.45
        Parameters.SubstitutionStrategySD = 0.18
        Parameters.IndexationStrategySD = 0.33
        Parameters.Phi_inflation = 0.1
        Parameters.Phi_unemployment = 0.8

    @classmethod
    def setExperiment7(cls):
        Parameters.setLearningLevel(1)
        Parameters.Ro = 0
        Parameters.SubstitutionStrategySD = 0.4
        Parameters.IndexationStrategySD = 0.16
        Parameters.Phi_inflation = 1.8
        Parameters.Phi_unemployment = 0.4

    @classmethod
    def setExperiment8(cls):
        Parameters.setLearningLevel(1)
        Parameters.Ro = 0.9
        Parameters.SubstitutionStrategySD = 0.41
        Parameters.IndexationStrategySD = 0.38
        Parameters.Phi_inflation = 1.6
        Parameters.Phi_unemployment = 0.6

    @classmethod
    def setExperiment9(cls):
        Parameters.setLearningLevel(1)
        Parameters.Ro = 0.45
        Parameters.SubstitutionStrategySD = 0.23
        Parameters.IndexationStrategySD = 0.23
        Parameters.Phi_inflation = 1
        Parameters.Phi_unemployment = 0.5

    @classmethod
    def setExperiment10(cls):
        Parameters.setLearningLevel(1)
        Parameters.Ro = 0
        Parameters.SubstitutionStrategySD = 0.12
        Parameters.IndexationStrategySD = 0.27
        Parameters.Phi_inflation = 1.5
        Parameters.Phi_unemployment = 0.1

    @classmethod
    def setExperiment11(cls):
        Parameters.setLearningLevel(2)
        Parameters.Ro = 0.9
        Parameters.SubstitutionStrategySD = 0.09
        Parameters.IndexationStrategySD = 0.2
        Parameters.Phi_inflation = 2
        Parameters.Phi_unemployment = 0.7

    @classmethod
    def setExperiment12(cls):
        Parameters.setLearningLevel(2)
        Parameters.Ro = 0.45
        Parameters.SubstitutionStrategySD = 0.38
        Parameters.IndexationStrategySD = 0.31
        Parameters.Phi_inflation = 1.8
        Parameters.Phi_unemployment = 0.2

    @classmethod
    def setExperiment13(cls):
        Parameters.setLearningLevel(2)
        Parameters.Ro = 0.45
        Parameters.SubstitutionStrategySD = 0.29
        Parameters.IndexationStrategySD = 0.05
        Parameters.Phi_inflation = 0.9
        Parameters.Phi_unemployment = 0.9

    @classmethod
    def setExperiment14(cls):
        Parameters.setLearningLevel(1)
        Parameters.Ro = 0
        Parameters.SubstitutionStrategySD = 0.25
        Parameters.IndexationStrategySD = 0.36
        Parameters.Phi_inflation = 1.4
        Parameters.Phi_unemployment = 1

    @classmethod
    def setExperiment15(cls):
        Parameters.setLearningLevel(0)
        Parameters.Ro = 0.45
        Parameters.SubstitutionStrategySD = 0.27
        Parameters.IndexationStrategySD = 0.12
        Parameters.Phi_inflation = 1.9
        Parameters.Phi_unemployment = 0.3

    @classmethod
    def setExperiment16(cls):
        Parameters.setLearningLevel(1)
        Parameters.Ro = 0.9
        Parameters.SubstitutionStrategySD = 0.05
        Parameters.IndexationStrategySD = 0.29
        Parameters.Phi_inflation = 0.3
        Parameters.Phi_unemployment = 0.6

    @classmethod
    def setExperiment17(cls):
        Parameters.setLearningLevel(1)
        Parameters.Ro = 0
        Parameters.SubstitutionStrategySD = 0.14
        Parameters.IndexationStrategySD = 0.07
        Parameters.Phi_inflation = 0.4
        Parameters.Phi_unemployment = 0.4
