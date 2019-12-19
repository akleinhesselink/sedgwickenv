rm(list = ls())

library(tidyverse)
library(ggmap)
library(ggrepel)
library(ggsn)
library(sp)
library(maptools)
library(cowplot)
library(sedgwickenv)
source('data-raw/scale_bar.R')
source('data-raw/register_google_api.R')

sedgwick_env <-
  sedgwick_env %>%
  mutate( site_label = ifelse(type == 'lower', paste0(site, " (", name , ")"), site))

my_map_theme <-
  theme_map() +
  theme(plot.margin = margin( 1, 1, 1, 1, unit = 'line'),
            panel.border = element_rect(fill = NA, color = 'black', size = 1))

boundary_df <- fortify(sedgwick_boundary)
mid_point <- aggregate( data =boundary_df , cbind(long, lat) ~ 1, FUN = 'mean')
mid_point <- mid_point + c(0, -0.018)

my_map <- get_map(location = mid_point, zoom = 13)

upper_points <-
  sedgwick_env %>%
  filter(type == 'upper') %>%
  dplyr::select(lon, lat, site) %>%
  SpatialPoints()

upper_bbox <-
  data.frame( val = matrix( raster::extent( upper_points ) ) + c(-0.002, 0.002),
              var = c('xmax', 'xmin', 'ymax', 'ymin')) %>%
  spread( var, val) %>%
  mutate( lon = 1, lat = 1)

m <- matrix( raster::extent(sedgwick_boundary) )

gg_full <-
  ggmap(my_map) +
  geom_polygon(data = boundary_df, aes( x = long, y = lat), fill = NA, color = 'black', size = 1.5) +
  geom_point(data = sedgwick_env, aes( x = lon, y = lat)) +
  geom_label_repel(data = sedgwick_env %>% filter(type == 'lower'),
                  aes( x = lon, y = lat, label = site), size = 3) +
  geom_rect(data = upper_bbox,
            aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax),
            fill = NA, color = 'black') +
  annotate( geom = 'label',
            x = upper_bbox$xmin + 0.01,
            y = upper_bbox$ymin + 0.006,
            label = 'Upper Sites\n(740-755)', size = 4) +
  annotate( geom = 'text',
            x = -120.0411,
            y = 34.676,
            label = 'Reserve Boundary', size = 4) +
  annotate( geom = 'segment', arrow = arrow(30, type = 'closed', length = unit(1, 'line')),
            x = m[2] + 0.01,
            y = m[3],
            xend = m[2] + 0.01,
            yend = m[3] + 0.01, size = 2) +
  annotate( geom = 'text', label = 'N', color = 'white', size = 4,
            x = m[2] + 0.01,
            y = m[3] + 0.0075) +
  my_map_theme

my_map_theme2 <- gg_full$theme


gg_full <-
  gg_full +
  scale_bar(lon = m[1] - 0.02,
            lat = m[3] - 0.005,
            distance_lon = 1,
            distance_lat = 0.2,
            distance_legend = 0.5,
            dist_units = 'km',
            orientation = TRUE)

# Map upper sites ------------------- #
upper_mid_point <- colMeans( matrix( raster::extent(upper_points), 2,2 ) )

upper_DEM <- raster::crop( sedgwick_DEM,
                           raster::extent(upper_points) + c(-0.002, 0.002, -0.002, 0.002) )

upper_DEM <- data.frame( raster::rasterToPoints(upper_DEM) )

upper_map <- get_map(location = upper_mid_point,
                     zoom = 18, maptype = 'satellite')

m <- ggmap(upper_map)
m <- data.frame( m$data ) %>% rename( 'x' = lon, 'y' = lat)

gg_upper <-
  ggmap(upper_map) +
  #geom_contour(data = upper_DEM, aes( x = x, y = y, z = w001001), alpha = 0.5) +
  geom_point(data = sedgwick_env %>% filter(type == 'upper'),
             aes( x = lon, y = lat, shape = microsite),
             size = 2) +
  scale_shape_manual(values = c(17,19)) +
  geom_label_repel(data = sedgwick_env %>% filter(type == 'upper'),
                  aes( x = lon, y = lat, label = site), size = 3, alpha = 0.7) +
  my_map_theme +
  theme(plot.margin = my_map_theme2$plot.margin,
        panel.border = my_map_theme2$panel.border,
        legend.title = element_blank(),
        legend.position = c(0.95, 0.12),
        legend.box.margin = margin(0.5, 0.5, 0.5, 0.5, unit = 'line'),
        legend.box.background = element_rect(fill = 'white', color = 'black'),
        legend.justification = 1,
        legend.direction = 'vertical')

gg_upper <-
  gg_upper +
  scale_bar(lon = m$x[1] + 0.0002,
            lat = m$y[1] + 0.0001,
            distance_lon = 50,
            distance_lat = 8,
            distance_legend = 16,
            dist_units = 'm')


ggsave( plot_grid(gg_full, gg_upper, labels = 'AUTO'),
        filename = 'man/figures/README-sedgwick_map.png', width = 8, height = 4, units = 'in')
