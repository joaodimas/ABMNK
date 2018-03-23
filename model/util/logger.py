"""

Code for my master thesis.

Still under development.

@author: João Dimas (joaohenriqueavila@gmail.com)

"""

import logging, os, numbers

class Logger:

    logger = None

    def info(self, message, args=None, economy=None):
        if(self.logger.isEnabledFor(logging.INFO)):
            self.logger.info(self.format(message, args, economy))

    def debug(self, message, args=None, economy=None):
        if(self.logger.isEnabledFor(logging.DEBUG)):
            self.logger.debug(self.format(message, args, economy))

    def trace(self, message, args=None, economy=None):
        if(self.logger.isEnabledFor(logging.TRACE)):
            self.logger.trace(self.format(message, args, economy))
            
    def exception(self, message):
        self.logger.exception(message)

    def isEnabledForTrace(self):
        return self.logger.isEnabledFor(logging.TRACE)

    def isEnabledForDebug(self):
        return self.logger.isEnabledFor(logging.DEBUG)

    def format(self, message, args, economy):
        if(economy != None):
            message = "[SCE {:02d}][EXP {:02d}][RUN {:02d}][T={:04d}] " + message
            if(isinstance(args, tuple)):
                args = (self.scenario, self.experiment, economy.simulationNumber, economy.currentPeriod) + args
            elif(args != None):
                args = (self.scenario, self.experiment, economy.simulationNumber, economy.currentPeriod, args)
            else:
                args = (self.scenario, self.experiment, economy.simulationNumber, economy.currentPeriod)
        if(isinstance(args, tuple)):
            message = message.format(*args)
        elif(isinstance(args, numbers.Number)):
            message = message.format(args)

        return message

    def __init__(self, timestamp, scenario, experiment, loglevel):
        self.scenario = scenario
        self.experiment = experiment
        #Add custom level TRACE
        logging.TRACE = 9
        logging.addLevelName(logging.TRACE, "TRACE")
        def trace(self, message, *args, **kws):
            if self.isEnabledFor(logging.TRACE):
                self._log(logging.TRACE, message, args, **kws)
        logging.Logger.trace = trace


        self.logger = logging.getLogger("ABMNK_[Sce:{:d}][Exp:{:d}]".format(scenario, experiment))
        self.logger.handlers.clear()
        if ("Console" in loglevel and "TRACE" in loglevel["Console"]) or ("File" in loglevel and "TRACE" in loglevel["File"]):
            self.logger.setLevel(logging.TRACE)
        elif ("Console" in loglevel and "DEBUG" in loglevel["Console"]) or ("File" in loglevel and "DEBUG" in loglevel["File"]):
            self.logger.setLevel(logging.DEBUG)
        elif ("Console" in loglevel and "INFO" in loglevel["Console"]) or ("File" in loglevel and "INFO" in loglevel["File"]):
            self.logger.setLevel(logging.INFO)
        else:
            self.logger.setLevel(logging.WARNING)

        THIS_FOLDER = os.path.dirname(os.path.abspath(__file__))

        # create a logging format
        formatter = logging.Formatter('%(message)s')

        if "Console" in loglevel and len(loglevel["Console"]) > 0:
            handler = logging.StreamHandler()
            handler.setFormatter(formatter)
            self.logger.addHandler(handler)
            # create a TRACE console handler
            if "TRACE" in loglevel["Console"]:
                handler.setLevel(logging.TRACE)
            elif "DEBUG" in loglevel["Console"]:
                handler.setLevel(logging.DEBUG)
            elif "INFO" in loglevel["Console"]:
                handler.setLevel(logging.INFO)
            else:
                handler.setLevel(logging.WARNING)

        try:
            os.mkdir(os.path.join(THIS_FOLDER, ("../../data")))                
        except:
            pass            
            
        # create an INFO file handler
        if "File" in loglevel:
            if("INFO" in loglevel["File"]):
                handler = logging.FileHandler(os.path.join(THIS_FOLDER, ("../../data/ABMNK.{}[Sce_{:d}][Exp_{:d}].INFO.log").format(timestamp.strftime("%Y-%m-%dT%Hh%Mm%Ss"), scenario, experiment)))
                handler.setLevel(logging.INFO)
                handler.setFormatter(formatter)
                self.logger.addHandler(handler)

            # create a DEBUG file handler
            if("DEBUG" in loglevel["File"]):
                handler = logging.FileHandler(os.path.join(THIS_FOLDER, ("../../data/ABMNK.{}[Sce_{:d}][Exp_{:d}].DEBUG.log").format(timestamp.strftime("%Y-%m-%dT%Hh%Mm%Ss"), scenario, experiment)))
                handler.setLevel(logging.DEBUG)
                handler.setFormatter(formatter)
                self.logger.addHandler(handler)

            # create a TRACE file handler
            if("TRACE" in loglevel["File"]):
                handler = logging.FileHandler(os.path.join(THIS_FOLDER, ("../../data/ABMNK.{}[Sce_{:d}][Exp_{:d}].TRACE.log").format(timestamp.strftime("%Y-%m-%dT%Hh%Mm%Ss"), scenario, experiment)))
                handler.setLevel(logging.TRACE)
                handler.setFormatter(formatter)
                self.logger.addHandler(handler)