# Macro Monitor

## Introduction
'Macro Monitor' is a project designed to track and monitor macroeconomic indicators. It utilizes R scripts to process and analyze data, generating insightful outputs based on predefined figures.

## Install
To install and set up the 'Macro Monitor' project, download [the latest and greatest source code](https://github.com/data-science-made-easy/macro-monitor/archive/refs/heads/master.zip) to the M-disk and unzip it.

### Directory Structure
After unzipping the project, you'll find the following files and directories.

- **figure-definition.xlsx**: this file defines the figures that will end up in your report
- **run-monitor.r**: this script starts the monitor
- **r/**: contains this project's r-scripts
- **run/**: directory where each run of the monitor is stored, organized by date and time.
  - **run-[date/time]**: subdirectory created for each run, containing:
    - **raw**: raw data (just a copy of the source data)
    - **preprocessed**: files that require some preprocessing (e.g. seasonal adjustment)
    - **output/**: Final output generated from the run.
        - **png/**: find your png files here
        - **macro-monitor-[date/time].html is final report as defined in **figure-definition.xlsx**

## Run

To run the 'Macro Monitor', execute the `run-monitor.r` script using R. This will initiate the data collection and processing workflow, creating a new run directory under `run/` with timestamped subdirectories for raw, preprocessed, and output data.

**A typical run:**

- update `figure-definition.xlsx` with your desired figures (details below)
- execute the script: `Rscript run-monitor.r`
- Check the `run` directory for the results of your monitor run (i.e, png's + a timestamped report.html)

## Details on figure-definition.xlxs
...
