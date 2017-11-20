# -*- coding: utf-8 -*-

from model.parameters import Parameters

class Scenario1:

    @classmethod
    def setLearningLevel(cls, level):
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

    @classmethod
    def setExperiment(cls, experiment):
        Parameters.AllHouseholdsSameExpectation = True # Coordination
        Parameters.NoiseInflationTargetPerceptionSD = 0 # Perfect precision
        Parameters.Chi = 1

        if experiment == 1:
            cls.setExperiment1()

    @classmethod
    def setExperiment1(cls):
        cls.setLearningLevel(1)
        Parameters.Ro = 0.9
        Parameters.SubstitutionStrategySD = 0.33
        Parameters.IndexationStrategySD = 0.18
        Parameters.Phi_inflation = 0.5
        Parameters.Phi_unemployment = 0.9

    @classmethod
    def setExperiment2(cls):
        cls.setLearningLevel(0)
        Parameters.Ro = 0.45
        Parameters.SubstitutionStrategySD = 0.36
        Parameters.IndexationStrategySD = 0.25
        Parameters.Phi_inflation = 0
        Parameters.Phi_unemployment = 0.3

    @classmethod
    def setExperiment3(cls):
        cls.setLearningLevel(0)
        Parameters.Ro = 0.45
        Parameters.SubstitutionStrategySD = 0.07
        Parameters.IndexationStrategySD = 0.14
        Parameters.Phi_inflation = 1.3
        Parameters.Phi_unemployment = 0.8

    @classmethod
    def setExperiment4(cls):
        cls.setLearningLevel(0)
        Parameters.Ro = 0.45
        Parameters.SubstitutionStrategySD = 0.16
        Parameters.IndexationStrategySD = 0.4
        Parameters.Phi_inflation = 1.1
        Parameters.Phi_unemployment = 0.1

    @classmethod
    def setExperiment5(cls):
        cls.setLearningLevel(2)
        Parameters.Ro = 0.9
        Parameters.SubstitutionStrategySD = 0.2
        Parameters.IndexationStrategySD = 0.09
        Parameters.Phi_inflation = 0.6
        Parameters.Phi_unemployment = 0

    @classmethod
    def setExperiment6(cls):
        cls.setLearningLevel(2)
        Parameters.Ro = 0.45
        Parameters.SubstitutionStrategySD = 0.18
        Parameters.IndexationStrategySD = 0.33
        Parameters.Phi_inflation = 0.1
        Parameters.Phi_unemployment = 0.8

    @classmethod
    def setExperiment7(cls):
        cls.setLearningLevel(1)
        Parameters.Ro = 0
        Parameters.SubstitutionStrategySD = 0.4
        Parameters.IndexationStrategySD = 0.16
        Parameters.Phi_inflation = 1.8
        Parameters.Phi_unemployment = 0.4

    @classmethod
    def setExperiment8(cls):
        cls.setLearningLevel(1)
        Parameters.Ro = 0.9
        Parameters.SubstitutionStrategySD = 0.41
        Parameters.IndexationStrategySD = 0.38
        Parameters.Phi_inflation = 1.6
        Parameters.Phi_unemployment = 0.6

    @classmethod
    def setExperiment9(cls):
        cls.setLearningLevel(1)
        Parameters.Ro = 0.45
        Parameters.SubstitutionStrategySD = 0.23
        Parameters.IndexationStrategySD = 0.23
        Parameters.Phi_inflation = 1
        Parameters.Phi_unemployment = 0.5

    @classmethod
    def setExperiment10(cls):
        cls.setLearningLevel(1)
        Parameters.Ro = 0
        Parameters.SubstitutionStrategySD = 0.12
        Parameters.IndexationStrategySD = 0.27
        Parameters.Phi_inflation = 1.5
        Parameters.Phi_unemployment = 0.1

    @classmethod
    def setExperiment11(cls):
        cls.setLearningLevel(2)
        Parameters.Ro = 0.9
        Parameters.SubstitutionStrategySD = 0.09
        Parameters.IndexationStrategySD = 0.2
        Parameters.Phi_inflation = 2
        Parameters.Phi_unemployment = 0.7

    @classmethod
    def setExperiment12(cls):
        cls.setLearningLevel(2)
        Parameters.Ro = 0.45
        Parameters.SubstitutionStrategySD = 0.38
        Parameters.IndexationStrategySD = 0.31
        Parameters.Phi_inflation = 1.8
        Parameters.Phi_unemployment = 0.2

    @classmethod
    def setExperiment13(cls):
        cls.setLearningLevel(2)
        Parameters.Ro = 0.45
        Parameters.SubstitutionStrategySD = 0.29
        Parameters.IndexationStrategySD = 0.05
        Parameters.Phi_inflation = 0.9
        Parameters.Phi_unemployment = 0.9

    @classmethod
    def setExperiment14(cls):
        cls.setLearningLevel(1)
        Parameters.Ro = 0
        Parameters.SubstitutionStrategySD = 0.25
        Parameters.IndexationStrategySD = 0.36
        Parameters.Phi_inflation = 1.4
        Parameters.Phi_unemployment = 1

    @classmethod
    def setExperiment15(cls):
        cls.setLearningLevel(0)
        Parameters.Ro = 0.45
        Parameters.SubstitutionStrategySD = 0.27
        Parameters.IndexationStrategySD = 0.12
        Parameters.Phi_inflation = 1.9
        Parameters.Phi_unemployment = 0.3

    @classmethod
    def setExperiment16(cls):
        cls.setLearningLevel(1)
        Parameters.Ro = 0.9
        Parameters.SubstitutionStrategySD = 0.05
        Parameters.IndexationStrategySD = 0.29
        Parameters.Phi_inflation = 0.3
        Parameters.Phi_unemployment = 0.6

    @classmethod
    def setExperiment17(cls):
        cls.setLearningLevel(1)
        Parameters.Ro = 0
        Parameters.SubstitutionStrategySD = 0.14
        Parameters.IndexationStrategySD = 0.07
        Parameters.Phi_inflation = 0.4
        Parameters.Phi_unemployment = 0.4