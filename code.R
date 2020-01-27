install.packages("jsonlite")

library(jsonlite)
library(dplyr)
library(ggplot2)
library(reshape2)
library(magrittr)
library(leaflet)
library(googleway)

full_data <- jsonlite::fromJSON("https://feeds.citibikenyc.com/stations/stations.json")

crashes <- jsonlite::fromJSON("https://data.cityofnewyork.us/resource/h9gi-nx95.json")

stations <- full_data$stationBeanList

str(crashes)

crashes <- crashes %>% mutate_at(vars(matches("number")), funs(as.numeric))


df <- mutate(crashes, total_affected_cyclist = (number_of_cyclist_killed + number_of_cyclist_injured))

# Most Dangerous borough

ggplot(data = df, aes(x = borough, y = total_affected_cyclist)) +
  geom_bar(stat = "identity")



mybins <- seq(0, 78, by 10)
mypalette <- colorBin(palette = "YlorBr", domain=stations$availableDocks, na.color="transparent", bins=mybins)

mytext <- paste(
  "Station Name: ", stations$stationName, "<br/>",
  "Total Docks: ", stations$totalDocks, "<br/>"
) %>%
  lapply(htmltools::HTML)

map <- leaflet(stations) %>%
  addTiles() %>%
  addProviderTiles("Esri.WorldImagery")%>%
  addCircleMarkers(~longitude, ~latitude,
                   fillColor = ~mypalette(availableDocks), fillOpacity = 0.7, color = "white", radius = 8, stroke = FALSE,
                   label = mytext,
                   labelOptions = labelOptions(style = list("font-weight"="normal", padding = "3px 8px"), textsize = "13px", direction = "auto")
                   ) %>%
  addLegend(pal = mypalette, values = ~availableDocks, opacity = 0.9, title = "Magnitude", position = "bottomright")

map