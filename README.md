<!-- rmarkdown v1 -->

# LawaEnsembleStats
R scripts to generate Ensemble Stats data in Hilltop format, as required by LAWA.

## Getting Started
These instructions will get you a copy of the project up and running on your local machine .

### Installing
Clone the repository to your machine.
Open the Refresh.Rproj file in R Studio.
Edit the settings.R file and enter the relevant information in it.
Run the RefreshStats.R script (Ctrl + A, then Run)

### Dependencies
The following packages will need to be installed:-

* RCurl
* dplyr
* lubridate
* XML
* data.table

They should get installed as required, but if there are any issues manually installing them may help.

## Overview
### Situation
LAWA currently requires ensemble stats for Rainfall and Groundwater level provided as seperate measurement time series.  The Hilltop Server can provide ensemble stats via a url call, but not in the format that LAWA requires.

The current process for generating the Hilltop file to provide the data is to generate the statistics from Hilltop Hydro and then use excel with Visual Basic Macros to create the Hilltop files.

These scripts provide an alternative method for generating the Hilltop files.

### Process
The scripts do the following:-

1. Download the LAWA MonitoringSitesWFS.
2. Identify the Groundwater Level and Rainfall Sites.
3. Retrieve the ensemble stats for each site for either rainfall or the relevant groundwater level measurement.
4. Process the ensemble stats from a generic month format into a timeseries.
5. Write csv files of the ensemble stats timeseries (for records, or potentially csv import).
6. Write Hilltop XML files that can be copied directly into Hilltop to provide the data via the Hiltop server.

### Settings
The script has been written to be flexible and hopefully allow other councils to use it.  Most of the settings that may need to be chaged are in the settings.R file.  The Hilltop XML Output measurement settings are contained in the measurementSettings.csv file, these should not need editing if the services were set up to be populated from the original excel / VB macros.

Variable | Description
:------------------------|:----------------------------------------------
wfs_MonitoringSites | The url of the wfs
rainfallEndpoint | The Hilltop web service providing the rainfall data
gwLevelEndpoint | The Hilltop web service providing the groundwater level data
rainfallMeasurementName | The measurement name for rainfall
gwLevelMeasurementName | The measurement name for groundwater level
startYr | The years that you want the output to start at
endYr | The years that you want the output to end at
outputDir | The directory that the output csv's are to be saved in, leave blank to save them to the same location as these files.
Agency | The Agency name for the Hilltop XML file.
RainfallStatsDatasource | The datasource name for the Rainfall Statistics.
GWLevelStatsDatasource | The datasource name for the Groundwater Statistics.

## Authors
* Jeff Cooke

## Licence

[![MIT license](https://img.shields.io/badge/license-MIT-brightgreen.svg)](http://opensource.org/licenses/MIT)

## Acknowledgments

* Sean Hodges - Horizons Regional Council for the original code for interacting with Hilltop servers, WFS and writing Hilltop XML files.