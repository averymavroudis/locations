library(dbscan)

clustering <- function(locations) {
  locations <- na.omit(locations)
  x <- as.matrix(locations[, 2:3])
  db <- dbscan(x, eps = .1)
  
  locations$cluster <- db$cluster
  clusterLatitudes <- with(locations, tapply(Latitude, cluster, mean))
  clusterLongitudes <-with(locations, tapply(Longitude, cluster, mean))
  clusterCoordinate <- as.table(cbind(clusterLatitudes, clusterLongitudes))
  
  clustCenters <- as.data.frame(table(db$cluster))
  clusterNumber <- clustCenters$Var1
  clusterDensity <- clustCenters$Freq
  
  output <- cbind(clusterDensity, clusterLatitudes, clusterLongitudes)
  as.data.frame(output)
}
