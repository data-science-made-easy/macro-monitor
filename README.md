# Macro Monitor

## Introduction
'Macro Monitor' is a project designed to monitor important macroeconomic indicators. It reads an xlsx-file with figure definitions, based on which it copies relevant source files, processes those files, and creates a report with png's.

## Install
To install and set up the 'Macro Monitor' project, download [the latest and greatest source code](https://github.com/data-science-made-easy/macro-monitor/archive/refs/heads/master.zip) to the M-disk and unzip it.

### Files and directory structure
After unzipping the project, you'll find the following files and directories:

- **figure-definition.xlsx**: here you select and define the figures that should end up in your report
- **run-monitor.r**: this script starts the monitor
- **r/**: contains this project's R scripts
- **run/**: directory where each run of the monitor is stored, organized by date and time
  - **run-[date/time]**: subdirectory created for each run, containing:
    - **raw**: raw data (just a copy of the source data)
    - **preprocessed**: files that require some preprocessing (e.g., seasonal adjustment)
    - **output**: final output generated from the run
      - **png/**: find your png files here
      - **macro-monitor-[date/time].html**: the final report as defined in **figure-definition.xlsx**

## Run
To run the 'Macro Monitor', execute the `run-monitor.r` script using R. This will initiate the data collection and processing workflow, creating a new run directory under `run/` with timestamped subdirectories for raw, preprocessed, and output data.

###A typical run:

1. update `figure-definition.xlsx` with your desired figures (details below)
2. start the monitor: `Rscript run-monitor.r`
3. check the `run` directory for the results of your monitor run (i.e., a timestamped report.html with png's)

## Details on figure-definition.xlsx
The xlsx has two tabs: settings, figures.

### Settings
In this tab set variables that apply to many lines in 'figures' tab. [TODO]

### Figures
This tab holds three categories of parameters: *Report*, *Preprocessing*, *Plot*. Lines in the xslx (i.e., time series) that share the same values for the *Report* parameters will show up in one single figure in the report.

#### Report
Lines that share the same settings for *report parameters* (section, subsection, tab) will show up in one single figure in the report. The file name of each figure on disk will be a polished combination of the report parameters (roughly speaking: *section*-*subsection*-*tab*.png).

#### Preprocessing
Parameters in this category determine the preprocessing of the data.

#### Plot
The monitor software will first combine parameter values for each parameter for each given figure that is defined on multiple lines in the xlsx file. Next, the parameters and their values will be sent to *nicerplot* (i.e., James' R-package) as is. Meaning, one can just add new parameters to the xlsx file as long as these are known to nicerplot.

NB Setting parameter 'file' will overwrite the default file name.