# ABMNK
Project for course Quantitative Methods in Finance, Prof. Eric Vansteenberghe.

Université Paris 1 Panthéon-Sorbonne

Program: Master 2 Financial Economics, 2017.

Authors: João Dimas (joaohenriqueavila@gmail.com) and Umberto Collodel (umberto.collodel@gmail.com)

Replication of an agent-based model described in:
Salle, I., Yıldızoğlu, M., & Sénégas, M.-A. (2013). Inflation targeting in a learning economy: An ABM perspective. Economic Modelling, 34, 114–128.

IMPORTANT: Spyder is not suitable to execute this simulation, since it adds a lot of overhead to processing. Please, execute using Terminal by navigating to ABMNK folder and running "python3 simulation.py"

This program must be executed by running simulation.py. Processors are used in their full capacity by parallelization. This program is scallable up to the number of RunsPerExperiment.
We used a server in Google Cloud with 20 processors to allow for executions in parallel with high performance.

- Have in mind that the multithread library is suitable for programs that have a high volume of I/O, but do not require much CPU. However, multithread library executes all threads in a single process, which is assigned a single processor by the operational system. Therefore, we use the multiprocessing library, which starts parallel process in the operational system, each of them being allowed to use different processors.

- Each execution of simulation.py will run all RunsPerExperiment and ExperimentsPerScenario for a given scenario. To simulate multiple scenarios, run simulation.py multiple times by setting the desired scenario each time.

- We added several assert statements to ensure consistency.

Setting up the simulation:

- System parameters are set in Simulation.SystemConfig:

    LogLevel: Set the log level (both for console and file output) among TRACE, DEBUG and INFO.
    EnableProfilingMainThread: Enable performance profiling in the main thread.
    Scenario: Number of the scenario you want to run. Each scenario must be set in scenarii.scenarii.py with a corresponding class in scenarii folder. Replaces parameters with scenario specific setting.
    ExperimentsPerScenario: Number of experiments per scenario. Each of them must be set in each scenario py file (scenarii folder). Replaces parameters with each experiment's specific setting.
    RunsPerExperiment: Number of independent executions of each experiment. This will be equal to the number of parallel processes.

- Standard model parameters are set in Parameters. They will be replaced when new parameters are set in Scenario or Experiment.
- Scenarios and experiments as described in the original paper are set in scenarii folder.

Analysing output:

- Results and logs are saved in data folder.
- Each scenario will generate log files as set in SystemConfig.LogLevel. Identify these files by the extension .log
- A .txt file will be generated for each experiment containing its parameters. Identify these files by the suffix "params".
- A single .csv file will be generated with the data for each run and each experiment collected every 50 periods (ignoring the first 100).
- A single .csv file will be generated with the aggregated data for all runs and experiments.