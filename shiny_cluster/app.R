library(shiny)
library(leaflet)
library(dbscan)
library(DT)

sampleLocations <- read.csv("./locations_sample.csv")

ui <- fluidPage(
  titlePanel("Clustering Locations"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("eps",
                  "Clustering Radius:",
                  min = 0.0,
                  max = 0.5,
                  step = 0.1,
                  value = 0.1),
      sliderInput("minPts",
                  "Minimum number of points per cluster:",
                  min = 1,
                  max = 10,
                  value = 5),
      selectInput("id", "ID:",
                    unique(sampleLocations$id))
    ),
    mainPanel(
      leafletOutput("leaflet39752"),
      dataTableOutput("clustTable")
    )
  )
)

server <- function(input, output) {

  output$leaflet39752 <- renderLeaflet({
    sampleLocations <- sampleLocations[sampleLocations$id == input$id, ]
    sampleLocations <- na.omit(sampleLocations)
    db <- dbscan(sampleLocations[,2:3], eps = input$eps, minPts = input$minPts)
    sampleLocations$cluster <- db$cluster
    clusters <- unique(db$cluster)
    if (!is.element(0, clusters)) {
      clusters <- c(0, clusters)
    }
    colors <- rainbow(length(clusters) - 1)
    colors <- c('#000000FF', colors)
    
    clusterLatLeaflet <- with(sampleLocations[sampleLocations$cluster != 0, ], tapply(latitude, cluster, mean))
    clusterLonLeaflet <- with(sampleLocations[sampleLocations$cluster != 0, ], tapply(longitude, cluster, mean))
    m <- leaflet(sampleLocations) %>%
      addProviderTiles(providers$CartoDB.Positron) %>%
      addCircleMarkers(lat = ~latitude, lng = ~longitude, color = colors[sampleLocations$cluster + 1L], stroke = FALSE)
    if (length(clusterLonLeaflet) != 0){
    m <-  addCircleMarkers(m, lat = clusterLatLeaflet, lng = clusterLonLeaflet, color = colors[-1], stroke = FALSE, radius = 50, fillOpacity = 0.3)
    }
    m
  })
 
  output$clustTable <- renderDataTable({
    sampleLocations <- sampleLocations[sampleLocations$id == input$id, ]
    sampleLocations <- na.omit(sampleLocations)
    db <- dbscan(sampleLocations[,2:3], eps = input$eps, minPts = input$minPts)
    sampleLocations$cluster <- db$cluster
    clusters <- unique(db$cluster)
    if (!is.element(0, clusters)) {
      clusters <- c(0, clusters)
    }
    colors <- rainbow(length(clusters) - 1)
    colors <- c('#000000FF', colors)
    
    clusterLatLeaflet <- with(sampleLocations[sampleLocations$cluster != 0, ], tapply(latitude, cluster, mean))
    clusterLonLeaflet <- with(sampleLocations[sampleLocations$cluster != 0, ], tapply(longitude, cluster, mean))
    
    df <- as.data.frame(table(db$cluster)) 
    if (is.element(0,df$Var1)){
      colors <- colors
    } else {
      colors <- colors[-1]
    }
    foo <- function(color){
      as.character(div(style = paste("background-color:",color,";height:15px;width:15px")))
    }
    table <- cbind(df, as.vector(sapply(colors,foo, simplify = "array")))
    table <- datatable(table, colnames = c("Cluster","Frequency","Color"), rownames= FALSE, escape = FALSE)
    table
  
  })
  
}

# Run the application 
shinyApp(ui = ui, server = server)
