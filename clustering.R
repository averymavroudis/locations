library(dbscan)

clustering <- function(locations) {
  locations <- na.omit(locations)
  x <- as.matrix(locations[, 2:3])
  db <- dbscan(x, eps = .1)

  locations$cluster <- db$cluster
  clusterLatitudes <- with(locations, tapply(Latitude, cluster, mean))
  clusterLongitudes <- with(locations, tapply(Longitude, cluster, mean))
  clusterCoordinate <- as.table(cbind(clusterLatitudes, clusterLongitudes))

  clustCenters <- as.data.frame(table(db$cluster))
  clusterNumber <- clustCenters$Var1
  clusterDensity <- clustCenters$Freq
  clusterCoordinate <- as.table(cbind(clusterLatitudes,clusterLongitudes))
  d <- distm(x,clusterCoordinate, fun = distGeo)
  avgDistToCenter <- as.vector((colSums(d)/nrow(d))/1609.34) #in miles
  densityRatio <- as.vector(clusterDensity/sum(clusterDensity))
  validSampleSize <- mapply(function(x,y){
    h <- (x*(1-x))/(.15/qnorm(.975))^2 
    h < y
    h
  }, densityRatio, clusterDensity)
  
  allData <- cbind(clusterNumber, clusterDensity, clusterLatitudes,clusterLongitudes, avgDistToCenter, densityRatio, validSampleSize)
  allData <- allData[clusterNumber != 0, ]
  as.data.frame(allData)
}
