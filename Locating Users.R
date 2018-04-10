list.of.packages <- c("geosphere","dbscan","data.table","utils")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
library("data.table")
filename <- "~/Documents/Stealz/Determining User's Central Location/Users's Locations - Locations.csv"
OutputFileName <- "~/Documents/Stealz/Determining User's Central Location/thisisatest.csv"
source("./Clustering.R")

ClusterMax <- function(userlocations){
  v <- clustering(userlocations)
  as.data.frame(v[which.max(v$ClusterDensity),])
  
}

userlocations <- read.csv(filename, header = TRUE)


locationsCSV <- function(data, fileName = ""){
  data <- sapply(split(data, data$Id),ClusterMax)
  data <- t(data)
  lat <- unlist(data[,2])
  lon <- unlist(data[,3])
  data <- as.data.frame(cbind(lat,lon))
  setDT(data,keep.rownames = TRUE)
  colnames(data) <- c("UserID","Latitude","Longitude")
  write.csv(data,file = fileName, row.names = FALSE)
}
