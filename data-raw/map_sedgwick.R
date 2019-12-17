rm(list = ls())
library(raster)
library(tidyverse)
library(sf)
library(ggmap)

DEM <- raster('data-raw/DEM/grdn35w121_13/w001001.adf')
boundary <- st_read('data-raw/gis_files/sedgwick_outline.kml')

boundary_polygon<-
  st_combine(boundary$geometry) %>%
  st_polygonize()%>%
  sf::as_Spatial()

# first crop by extent then use mask #####
r2 <- crop(DEM, extent(boundary_polygon)+0.01) ###+0.01 make white space around the raster
r3 <- mask(r2, boundary_polygon)

### read location ######
locations <- read_csv('data-raw/plot_locations.csv')
locations <- st_as_sf(locations, coords = c("x", "y"), crs = 4326, agr = "constant")
locations <-
  locations %>%
  dplyr::select( name, lat, lon, ele) %>%
  mutate( group = ifelse ( lat > 34.72 , 'upper', 'lower'))

# --------------------------
plot(r3)
plot(boundary_polygon, add = T)
contour(r3, add = T, lwd = 0.1)
plot(locations,  add = T, pch = 19, color = 'black')

label_adj <-
  data.frame( name = c(756:763),
            lat_adj = c(0.003,
                        -0.003,
                        0.002,
                        -0.002,
                        0.003,
                        -0.003,
                        0.003,
                        -0.003),
            lon_adj = c(0.004,
                         0.004,
                         -0.005,
                         -0.005,
                         0.004,
                         0.004,
                         -0.006,
                         0.006))


my_labels <-
  left_join(locations, label_adj) %>%
  mutate( lat_lab = lat + lat_adj ,
          lon_lab = lon + lon_adj,
          label = as.numeric(factor(name)))

text(my_labels$lon_lab, my_labels$lat_lab, label = my_labels$label)

upper_box <-
  locations %>%
  filter( group == 'upper') %>%
  summarise( x1 = min(lon) - 0.001,
             x2 = max(lon) + 0.001,
             y1 = min(lat) - 0.001,
             y2 = max(lat) + 0.001 ) %>%
  data.frame() %>%
  dplyr::select(-geometry)


upper_box_extent <- extent( as.numeric( upper_box)  )

rect(xleft = upper_box$x1,
     xright = upper_box$x2,
     ybottom = upper_box$y1,
     ytop = upper_box$y2)

text( upper_box$x2 + 0.004, upper_box$y2 + 0.002, 'Upper Sites', cex = 1)
title(main = 'Sampling Sites\nSedgwick Reserve, CA, USA')

r_upper <- crop( r3, upper_box_extent )
plot(r_upper)
contour(r_upper, add = T)
plot(locations, add = T, color = 'black', pch = 19)






