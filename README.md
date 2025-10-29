# Macro Monitor

## Introduction
'Macro Monitor' is a system that monitors important macroeconomic indicators. It reads an xlsx file with figure definitions, based on which it retrieves relevant source files. It processes those files, and creates a report with png's.

## Install
To install and set up the Macro Monitor, download [the latest and greatest source code](https://github.com/data-science-made-easy/macro-monitor/archive/refs/heads/master.zip) to the M-disk and unzip it.

### Files and directory structure
After unzipping, you’ll find the following files and directories. All key information (figure definitions, order, templates, file paths, axis ranges) is centralized, which makes the software both easy to run and maintain.

- **figure-definition.xlsx**: here you select and define the figures that should end up in your report
  - **tab `settings`** contains variables (pointing to files, defining zoom levels for axes, defining output path (`path_run`) etc.)
  - **tab `figures` describes the figures in detail
- **run-monitor.r**: this script starts the monitor
- **r/**: contains the project's R scripts
- **run/**: directory where each run of the monitor is stored, organized by date and time
  - **run-[date/time]** (see variable `path_run`): subdirectory created for each run, containing:
    - **report/macro-monitor-[date/time].html**: the final report as defined in **figure-definition.xlsx**
    - **png/**: find your png files here
    - **xlsx/** with:
      - **raw**: raw time series (as found in the source data)
      - **preprocessed**: preprocessed time series (e.g., seasonal adjustment, indexing)

Running the monitor (see below how to do so) creates a directory as defined in variable `path_run` in the settings tab of 'figure-definition.xlsx'. If you leave `path_run` empty, then it creates a directory `run` with subdirectory `run-date-time`, with the actual values for date and time at the moment you start the software. This enables you to run the monitor several times with different settings without overwriting.

## Run
To run the 'Macro Monitor', execute the `run-monitor.r` script using R. This will initiate the data collection and processing workflow, creating a new run directory under `run/` with timestamped subdirectories for raw, preprocessed, and output data.

### A typical run:

1. update `figure-definition.xlsx` with your desired figures (details below)
2. start the monitor: `Rscript run-monitor.r`
3. check the `run` directory for the results of your monitor run (i.e., a timestamped report.html with png's)

## Details on figure-definition.xlsx
The xlsx has two tabs: settings, figures.

The **'settings' tab** configures variables that apply to the many rows in 'figures' tab. These variables enable you to conveniently update / improve the monitor and its figures.

The **'figures' tab** holds three categories of parameters: **report**, **data / processing settings **, and **plot settings**. Each row in the 'figures' tab refers to one single time series. Rows in the 'figures' tab that share the same settings for *report parameters* (section, subsection, tab) will show up in one single figure in the report. One figure hence may show multiple time series.

Examples of **data / processing settings**:

- In which file the series is located  
- On which sheet of that file the series is located  
- The name of the series in the source file  
- The name the series should have in the monitor  
- The frequency of the series in the source sheet  
- The frequency at which the series should be displayed in the monitor (the software converts the data accordingly)
- (Optional) The base year to which the series should be indexed
  _Note: if the series has multiple values for the chosen base year, the average of those values is used._  
- (Optional) If you want “cumulative composition” or “cumulative growth,” specify a base year to normalize the values of the time series  
  _Note: if the series has multiple values for the chosen base year, only the first value is used._  
- Whether a difference with a previous period should be calculated (and if so, how many time steps back)  
- Whether that difference should be shown as a percentage  
- Whether seasonal adjustment should be applied (it's as easy as placing a 'y' in the respective column)

Examples of **plot settings**:

- Titles: figure, left y-axis, right y-axis, x-axis
- Footnote
- Legend (yes/no), number of series per column, …
- Display style per series (line, dashed, bar, …)
- Whether scaling should be applied
- Axis range (e.g., use ${last_20_years} so you don’t have to manually update the values as time progresses)
