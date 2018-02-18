"""

Code for my master thesis.

Still under development.

@author: João Dimas (joaohenriqueavila@gmail.com)

"""

import logging, os, numbers

class Logger:

    logger = None

    @classmethod
    def info(cls, message, args=None, economy=None):
        if(cls.logger.isEnabledFor(logging.INFO)):
            cls.logger.info(cls.format(message, args, economy))

    @classmethod
    def debug(cls, message, args=None, economy=None):
        if(cls.logger.isEnabledFor(logging.DEBUG)):
            cls.logger.debug(cls.format(message, args, economy))

    @classmethod
    def trace(cls, message, args=None, economy=None):
        if(cls.logger.isEnabledFor(logging.TRACE)):
            cls.logger.trace(cls.format(message, args, economy))

    @classmethod
    def isEnabledForTrace(cls):
        return cls.logger.isEnabledFor(logging.TRACE)

    @classmethod
    def isEnabledForDebug(cls):
        return cls.logger.isEnabledFor(logging.DEBUG)

    @classmethod
    def format(cls, message, args, economy):
        if(economy != None):
            message = "[RUN {:02d}][T={:04d}] " + message
            if(isinstance(args, tuple)):
                args = (economy.simulationNumber, economy.currentPeriod) + args
            elif(args != None):
                args = (economy.simulationNumber, economy.currentPeriod, args)
            else:
                args = (economy.simulationNumber, economy.currentPeriod)
        if(isinstance(args, tuple)):
            message = message.format(*args)
        elif(isinstance(args, numbers.Number)):
            message = message.format(args)

        return message

    @classmethod
    def initialize(cls, timestamp, loglevel):

        #Add custom level TRACE
        logging.TRACE = 9
        logging.addLevelName(logging.TRACE, "TRACE")
        def trace(self, message, *args, **kws):
            if self.isEnabledFor(logging.TRACE):
                self._log(logging.TRACE, message, args, **kws)
        logging.Logger.trace = trace


        cls.logger = logging.getLogger("ABMNK")
        cls.logger.handlers.clear()
        if ("Console" in loglevel and "TRACE" in loglevel["Console"]) or ("File" in loglevel and "TRACE" in loglevel["File"]):
            cls.logger.setLevel(logging.TRACE)
        elif ("Console" in loglevel and "DEBUG" in loglevel["Console"]) or ("File" in loglevel and "DEBUG" in loglevel["File"]):
            cls.logger.setLevel(logging.DEBUG)
        elif ("Console" in loglevel and "INFO" in loglevel["Console"]) or ("File" in loglevel and "INFO" in loglevel["File"]):
            cls.logger.setLevel(logging.INFO)
        else:
            cls.logger.setLevel(logging.WARNING)

        THIS_FOLDER = os.path.dirname(os.path.abspath(__file__))

        # create a logging format
        formatter = logging.Formatter('%(message)s')

        if "Console" in loglevel and len(loglevel["Console"]) > 0:
            handler = logging.StreamHandler()
            handler.setFormatter(formatter)
            cls.logger.addHandler(handler)
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
                handler = logging.FileHandler(os.path.join(THIS_FOLDER, ("../../data/ABMNK.{}.INFO.log").format(timestamp.strftime("%Y-%m-%dT%Hh%Mm%Ss"))))
                handler.setLevel(logging.INFO)
                handler.setFormatter(formatter)
                cls.logger.addHandler(handler)

            # create a DEBUG file handler
            if("DEBUG" in loglevel["File"]):
                handler = logging.FileHandler(os.path.join(THIS_FOLDER, ("../../data/ABMNK.{}.DEBUG.log").format(timestamp.strftime("%Y-%m-%dT%Hh%Mm%Ss"))))
                handler.setLevel(logging.DEBUG)
                handler.setFormatter(formatter)
                cls.logger.addHandler(handler)

            # create a TRACE file handler
            if("TRACE" in loglevel["File"]):
                handler = logging.FileHandler(os.path.join(THIS_FOLDER, ("../../data/ABMNK.{}.TRACE.log").format(timestamp.strftime("%Y-%m-%dT%Hh%Mm%Ss"))))
                handler.setLevel(logging.TRACE)
                handler.setFormatter(formatter)
                cls.logger.addHandler(handler)