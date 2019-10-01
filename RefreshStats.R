# Bring in the helper functions
source("refreshHelpers.R")
source("writeHilltopXML.R")

# Edit the settings.R file so that all of the data is correct for the agency / situation.
source("settings.R")

#For Rainfall Stats and GWLevel stats

#Read Monitoring sites WFS to get a list of sites.
sites <- readWFS(wfs_MonitoringSites)

#Trim the data frame to just the required columns
sites <- subset(sites, select = c("CouncilSiteID", "Rainfall", "GWLevel"))

#Create list of rainfall sites
rainSites <- subset(sites, Rainfall == "Yes")

#Create list of GW level sites
gwLevelSites <- subset(sites, GWLevel == "Yes")

#For each rainfall site get the Rainfall stats

rainStat <- siteMonthlyStat(sitelist = rainSites$CouncilSiteID, 
                            endpoint = rainfallEndpoint, 
                            measurement = rainfallMeasurementName, 
                            startYr = startYr, 
                            endYr = endYr)

#For each site get the GW level stats
gwLevelStat <- siteMonthlyStat(sitelist = gwLevelSites$CouncilSiteID, 
                            endpoint = gwLevelEndpoint, 
                            measurement = gwLevelMeasurementName, 
                            startYr = startYr, 
                            endYr = endYr)


# Output csv's (original intent was to use these to import into Hilltop, but ran into issues)

write.csv(rainStat, file = paste0(outputDir, "rainfallStats.csv"), row.names = FALSE)
write.csv(gwLevelStat, file = paste0(outputDir, "gwLevelStats.csv"), row.names = FALSE)

# Create Hilltop XML files.
# Import the measurement list settings from the csv file
mList <- read.csv("measurementSettings.csv", stringsAsFactors = FALSE)
# create the hilltop XML for rainfall based on the settings file and data passed in
writeEnsembleHilltop(rainStat, Agency, RainfallStatsDatasource, subset(mList, DataSource == "Rainfall"))
# create the hilltop XML for GW Level based on the settings file and data passed in
writeEnsembleHilltop(gwLevelStat, Agency, GWLevelStatsDatasource, subset(mList, DataSource == "GWLevel"))
