rm(list = ls())
library(raster)
library(tidyverse)
library(sf)

DEM <- raster('data-raw/DEM/grdn35w121_13/w001001.adf')
boundary <- st_read('data-raw/gis_files/sedgwick_outline.kml')

sedgwick_boundary <-
  st_combine(boundary$geometry) %>%
  st_polygonize()%>%
  sf::as_Spatial()

sedgwick_DEM <- crop(DEM, sedgwick_boundary)

usethis::use_data(sedgwick_DEM, overwrite = T)
usethis::use_data(sedgwick_boundary, overwrite = T)

