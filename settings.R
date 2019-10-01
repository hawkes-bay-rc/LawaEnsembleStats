##Council or run related information.
#Edit these values to the appropriate ones for your system

#The url for your Monitoring sites reference data WFS, can be copied and pasted out of LAWA Umbraco
wfs_MonitoringSites <- c("https://hbmaps.hbrc.govt.nz/arcgis/services/emar/MonitoringSiteReferenceData/MapServer/WFSServer?request=GetFeature&service=WFS&typename=MonitoringSiteReferenceData&srsName=urn:ogc:def:crs:EPSG:6.9:4326&Version=1.1.0")

#The Hilltop web service providing the rainfall data
rainfallEndpoint <- c("https://data.hbrc.govt.nz/EnviroData/EMAR.hts?")

#The Hilltop web service providing the groundwater level data
gwLevelEndpoint <- c("https://data.hbrc.govt.nz/EnviroData/EMAR.hts?")

#The measurement names for the rainfall and groundwater level data
rainfallMeasurementName <- "Rainfall"
gwLevelMeasurementName <- "Elevation Above Sea Level [Manual Water Level]"

#The years that you want the output to start at and end at
startYr <- 2010
endYr <- 2020

#The directory that the output csv's are to be saved in, leave blank to save them to the same location as these files.
outputDir <- ""

#Hilltop XML Output settings, measurement settings contained in the measurementSettings.csv file
Agency <- "HBRC"
RainfallStatsDatasource <- "Ensemble Rainfall Statistics"

GWLevelStatsDatasource <- "Ensemble Groundwater Statistics"
