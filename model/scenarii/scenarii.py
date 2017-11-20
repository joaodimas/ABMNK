# -*- coding: utf-8 -*-

from model.scenarii.scenario1 import Scenario1
class Scenarii:

    @classmethod
    def setExperiment(cls, scenario, experiment):
        if scenario == 1:
            Scenario1.setExperiment(experiment)