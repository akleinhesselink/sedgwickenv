library(raster)
library(dplyr)
library(tidyr)

DEM <- raster('~/Downloads/grdn35w121_13/w001001.adf')

plot_locations <- read.csv('~/Dropbox/Sedgwick/spatial_tapioca/data/environmental/plot_locations.csv')

plot_locations <- plot_locations %>% select( name, lat, lon, ele)

e <- extent(x = c( range(plot_locations$lon), range(plot_locations$lat)))
            
DEM <- crop(DEM, e*1.1)

plot(DEM)
contour(DEM, add = T)
points(plot_locations$lon, plot_locations$lat, pch = 19)

plot_locations <- plot_locations %>% mutate( group =  ifelse ( lat < 34.72, 'lower', 'upper') )

upper <- subset(plot_locations , group == 'upper')
lower <- subset(plot_locations, group == 'lower')

e_upper <- extent( x = c(min(upper$lon), max(upper$lon), min(upper$lat), max(upper$lat) ) )
DEM_upper <- crop(DEM, e_upper*1.1)        

e_lower <- extent(x = c(min(lower$lon), max(lower$lon), min(lower$lat), max(lower$lat)))
DEM_lower <- crop(DEM, e_lower*1.1)

plot(DEM_upper)
contour(DEM_upper, add = T)
points(upper$lon, upper$lat, pch = 19)

plot(DEM_lower)
contour(DEM_lower, add = T)
points(lower$lon, lower$lat, pch = 19)


plot(DEM)
contour(DEM, add = T, nlevels = 5)
points(plot_locations$lon, plot_locations$lat, pch = 19)

X <- plot_locations 
coordinates(X) <- c('lon', 'lat')

X$elevation <- raster::extract(DEM, X)

X
plot_locations$ele

