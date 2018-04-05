library(dbscan)
library(utils)

clustering <- function(locations) {
  locations <- na.omit(locations)
  x <- as.matrix(locations[,2:3])
  db <- dbscan(x, eps = .1)
  
  locations$cluster <- db$cluster
  clusterLatitudes <- with(locations, tapply(Latitude, cluster, mean))
  clusterLongitudes <-with(locations, tapply(Longitude, cluster, mean))
  clusterCoordinate <- as.table(cbind(clusterLatitudes,clusterLongitudes))
  
  clustcenters <- as.data.frame(table(db$cluster))
  ClusterNumber <- clustcenters$Var1
  ClusterDensity <- clustcenters$Freq
  
  output <- cbind(ClusterDensity,clusterLatitudes,clusterLongitudes)
  as.data.frame(output)
}
