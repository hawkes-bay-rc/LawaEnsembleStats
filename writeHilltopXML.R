## Load libraries ------------------------------------------------

#Install the required packages
pkgs <- c('XML', 'dplyr', 'lubridate')
if(!all(pkgs %in% installed.packages()[, 'Package']))
  install.packages(pkgs, dep = T)

require(XML)     ### XML library to write hilltop XML
require(dplyr)
require(lubridate)  ###Date handling library


writeEnsembleHilltop <- function(ensembleData, agency, dataSource, measList) {
  #Function to create a Hilltop XML file from rainfall, or gw level ensemble stats datafiles.
  #The agency and datasource information need to be passed into the function, along with the measurement list settings
  #Create / update mowsecs column (making sure NZ time correction done) 
  #Hilltop / sample time is NZ time zone, Mowsecs are the number of seconds since 1 Jan 1940 in UTC time!  Lubridate helps a lot.
  mowsecRefDate <- with_tz(ymd("1940-01-01"), "UTC")
  ensembleData$mowsecs <- difftime(with_tz(parse_date_time(ensembleData$Date, "Ymd"), "NZ"), mowsecRefDate, unit="secs")
  #Make sure data is ordered by site, and mowsecs
  ensembleData <- ensembleData[order(ensembleData$Site, ensembleData$mowsecs),]
  
  #Order the measList by ItemNo
  measList <- measList[order(measList$ItemNo),]
  nItems <- nrow(measList)
  
  siteList <- unique(as.character(ensembleData$Site))
  ## Build XML Document --------------------------------------------
  
  con <- xmlOutputDOM("Hilltop")
  con$addTag("Agency", agency)
  
  max<-nrow(ensembleData)
  #for each site
  for(s in 1:length(siteList)){
    site <-siteList[s]
    siteMeas <- subset(ensembleData, Site == site)
    
    con$addTag("Measurement",  attrs=c(SiteName=site), close=FALSE)
    con$addTag("DataSource",  attrs=c(Name=dataSource,NumItems=nItems), close=FALSE)
    con$addTag("TSType", "StdSeries")
    con$addTag("DataType", "SimpleTimeSeries")
    con$addTag("Interpolation", "Histogram")
    con$addTag("ItemFormat", "0")
    for(i in 1:nItems) {
      con$addTag("ItemInfo", attrs=c(ItemNumber=measList$ItemNo[i]),close=FALSE)
      con$addTag("ItemName", measList$AgencyMeasurementName[i])
      con$addTag("Divisor", "1")
      con$addTag("Units", measList$Units[i])
      con$addTag("Format", '#.##')
      con$closeTag() # ItemInfo
    } #end for loop
        
    con$closeTag() # DataSource
    con$addTag("Data", attrs=c(DateFormat="mowsecs", NumItems=nItems),close=FALSE)
    for(m in 0:nrow(siteMeas)){  
      data <- as.character(siteMeas$mowsecs[m])
      #Build the line of data
      for(r in 1:nItems) {
        data <- paste(data, siteMeas[[measList$Measurement[r]]][m])
      } 
      #Add in the data
      con$addTag("V", data)
    } # end for loop for data
    
    con$closeTag() # Data
    con$closeTag() # Measurement
    }# end for loop for sites
  
  con$closeTag() # Hilltop
  saveXML(con$value(), file=paste(dataSource, "_EnsembleStats_",Sys.Date(),".xml",sep=""))
} #end function


