source("./Clustering.R")
library(geosphere)
AllData <- function(userlocations){
  clustering(userlocations)
  clusterCoordinate <- as.table(cbind(clusterLatitudes,clusterLongitudes))
  d <- distm(x,clusterCoordinate, fun = distGeo)
  AvgDistToCenter <- as.vector((colSums(d)/nrow(d))/1609.34) #in miles
  densityRatio <- as.vector(ClusterDensity/sum(ClusterDensity))
  
  ValidSampleSize <- mapply(function(x,y){
    h <- (x*(1-x))/(.15/qnorm(.975))^2 
    h < y
    h
  })
  
  alldata <- cbind(ClusterNumber, clustering$ClusterDensity, clustering$clusterLatitudes,clustering$clusterLongitudes, AvgDistToCenter, densityRatio, ValidSampleSize)
  alldata<- alldata[ClusterNumber != 0,]
  
  clustersforleaflet <- unique(db$cluster)
  if (!is.element(0, clustersforleaflet)) {
    clustersforleaflet <- c(0, clustersforleaflet)
  }
  colors <- rainbow(length(clusters) - 1)
  colors <- c('#000000', colors)
  
  
  clusterLatLeaflet <- with(Visualize[Visualize$cluster != 0,], tapply(Latitude, cluster, mean))
  clusterLonLeaflet <-with(Visualize[Visualize$cluster != 0,], tapply(Longitude, cluster, mean))
  library(leaflet)
  m <- leaflet(locations) %>%
    addProviderTiles(providers$CartoDB.Positron) %>%
    addCircleMarkers(lat = ~Latitude, lng = ~Longitude, color = colors[locations$cluster + 1L], label = ~City, stroke = FALSE) %>%
    addCircleMarkers(lat = clusterLatLeaflet, lng = clusterLonLeaflet, color = colors[-1], stroke = FALSE, radius = 50, fillOpacity = 0.3)
  m
}

lapply(split(userlocations,userlocations$UserId),AllData)



