#library(XML)
#library(RCurl)

pkgs <- c('RCurl', 'dplyr','XML', 'lubridate', 'data.table')
if(!all(pkgs %in% installed.packages()[, 'Package']))
  install.packages(pkgs, dep = T)

require(RCurl)
require(dplyr)
require(lubridate)
require(XML)
require(data.table)


#Hilltop.R will be required, need to store it somehwere that will be available for use, or obtain from Github.
#If Hilltop.R (or equivalent) is stored locally then source it directly
#source("Hilltop.R")


#To source direct from Github (requires internet access) (Slow)


script <- getURL("https://raw.githubusercontent.com/jeffcnz/Hilltop/master/Hilltop.R", ssl.verifypeer = FALSE) 

eval(parse(text = script)) 



# Function to read a Monitoring Sites Reference Data WFS into a data.frame
readWFS <- function(url){
  #Function to read a WFS and return a dataframe
  cat(url,"\n")
  
  # Dealing with https:
  if(substr(url,start = 1,stop = 5)=="http:"){
    getSites.xml <- xmlInternalTreeParse(url)
  } else {
    tf <- getURL(url, ssl.verifypeer = FALSE)
    
    getSites.xml <- xmlParse(tf)
  }
  
  ds <- xmlToDataFrame(getNodeSet(getSites.xml, "//emar:MonitoringSiteReferenceData"))
  
  ds$Source <- url
  ds
}


# Function to retrieve ensemble stats from a Hilltop server.
getEnsembleStats <- function(endpoint, site, measurement, statistic, lowerPercentile, upperPercentile, from, to){
  if(missing(statistic) | !(statistic %in% c("MonthlyPDF"))){
    message("Valid statistic function must be provided")
    return("Error")
  }
  if(missing(lowerPercentile)){lowerPercentile <- 25}
  if(missing(upperPercentile)){upperPercentile <- 75} 
  if(missing(from)){from <- "01/01/1900"}
  if(missing(to)){to <- ""}
  # create an empty dataframe to append the results to for eventual output
  output<-data.frame(Site=character(), 
                     stringsAsFactors=FALSE) 
  
  message(paste("Requesting", site, measurement))
  #build the request
  testrequest <- paste("Service=Hilltop&Request=EnsembleStats&Site=", site, 
                        "&Measurement=", measurement, 
                        "&Statistic=", statistic,
                        "&LowerPercentile=", lowerPercentile, 
                        "&UpperPercentile=", upperPercentile,
                        "&From=", from,
                        "&To=", to,
                        sep="")
  #get the xml data from the server
  url<-paste(endpoint, testrequest, sep="")
  #message(url)
  dataxml<-anyXmlParse(URLencode(url))
  #convert the xml into a dataframe of measurement results
  #with basic error handling
  ensembleStat <- tryCatch({
      hilltopEnsembleStatFull(dataxml)
    }, error=function(err){message(paste("Error retrieving", site, measurement))})
      
  output <- rbind(output, ensembleStat)
  return(output)   
}

# Function to generate a data frame of ensemble stats for each site and month 
siteMonthlyStat <- function(sitelist, endpoint, measurement, startYr, endYr){
  # Generate the site monthly stats dataframe for all of the years and sites requested.
  # Generate the site monthly stats for the measurement
  siteStat <- lapply(sitelist, getEnsembleStats, endpoint = endpoint, measurement = measurement, statistic = "MonthlyPDF")
  #Efficiently convert the list output to a dataframe
  siteStatDf <- rbindlist(siteStat, fill=TRUE)
  #Repeat for each year
  siteStatDfYr <- cbind(siteStatDf, Year=rep(startYr:endYr, each=nrow(siteStatDf)))
  
  #Rename Columns
  siteStatDfYr <- dplyr::rename(siteStatDfYr, 
      Percentile.25 = LowerPercentile.y,
      Percentile.75 = UpperPercentile.y
    )
  #Calculate date field (at the beginning of the next month)
  siteStatDfYr$Date <- ceiling_date(dmy(paste("01", siteStatDfYr$periodID, siteStatDfYr$Year)), unit="month")#-days(1)
  
  #Remove columns and order
  siteStatFinal <- subset(siteStatDfYr, select = c("Site", 
                                                   "Date", 
                                                   "Min", 
                                                   "Percentile.25", 
                                                   "Median", 
                                                   "Percentile.75", 
                                                   "Max", 
                                                   "Mean"))
  #Sort by site and date
  siteStatFinal <- siteStatFinal[order(Site, Date)]
  return(siteStatFinal)
}
