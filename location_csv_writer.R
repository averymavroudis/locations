source("./Clustering.R")
source("./init.R")
library(data.table)

maxCluster <- function(userlocations){
  v <- clustering(userlocations)
  as.data.frame(v[which.max(v$clusterDensity), ])
}

locationsCSV <- function(data, fileName = ""){
  if (missing(fileName)){
    warning("fileName required to save CSV in directory")
  }
  data <- sapply(split(data, data$id), maxCluster)
  data <- t(data)
  lat <- unlist(data[, 2])
  lon <- unlist(data[, 3])
  data <- as.data.frame(cbind(lat, lon))
  setDT(data, keep.rownames = TRUE)
  colnames(data) <- c("id", "latitude", "longitude")
  write.csv(data, file = fileName, row.names = FALSE)
}
