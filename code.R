#install packages
install.packages("jsonlite", "dplyr", "ggplot2", "reshape2", "magrittr", "leaflet", "forcats", "tidyr", "devtools", "htmlwidgets")

#Import Library
library(jsonlite)
library(dplyr)
library(ggplot2)
library(reshape2)
library(magrittr)
library(leaflet)
library(forcats)
library(tidyr)
library(htmlwidgets)

#Import Data
full_data <- jsonlite::fromJSON("https://feeds.citibikenyc.com/stations/stations.json")
crashes <- jsonlite::fromJSON("https://data.cityofnewyork.us/resource/h9gi-nx95.json")

#Pull out stations data
stations <- full_data$stationBeanList

#Change Data type
crashes <- crashes %>% mutate_at(vars(matches("number")), funs(as.numeric))

#Create a new column adding the number of people affected in bike crash
df <- mutate(crashes, total_affected_cyclist = (number_of_cyclist_killed + number_of_cyclist_injured))


# Visualizing the most most dangerous borough
cyclist_crashed <- ggplot(df, aes(x=borough, y=total_affected_cyclist)) + 
                      geom_bar(stat = "identity", fill="#f68060", alpha =.6, width = .4) +
                      coord_flip()+
                      xlab("") +
                      theme_bw() +
                      ggtitle("Total Number of Cyclist involved in Bike crash in New York")

#Save vizualization
ggsave("cyclist_crashed.png")


# Create a color palette
mybins <- seq(0, 72, by=15)
mypalette <- colorBin(palette = "YlOrBr", domain=stations$availableBikes, na.color="transparent", bins=mybins)

# Prepare the tooltip
mytext <- paste("Station Name: ", stations$stationName) %>% 
  lapply(htmltools::HTML)

# Map visualization
map <- leaflet(stations) %>%
  addTiles() %>%
  addProviderTiles("Esri.WorldImagery")%>%
  addCircleMarkers(~longitude, ~latitude,
                   fillColor = ~mypalette(availableBikes), fillOpacity = 0.7, color = "white", radius = 5, stroke = FALSE,
                   label = mytext,
                   labelOptions = labelOptions(style = list("font-weight"="normal", padding = "3px 8px"), textsize = "13px", direction = "auto")
                   ) %>%
  addLegend(pal = mypalette, values = ~availableBikes, opacity = 0.9, title = "Number of Available bikes", position = "bottomright")

#Save visualization
saveWidget(map, "bikes_available.html", selfcontained = FALSE)