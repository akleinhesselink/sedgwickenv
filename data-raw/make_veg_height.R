rm(list = ls() )
library(tidyverse)

height <- read_csv('data-raw/2019_veg_heights.csv')
depth <- read_csv('data-raw/soil_depths.csv')

height <- height %>%
  pivot_longer(  `1`:`5_1`, 'plot' ) %>%
  separate( plot, 'plot' , sep = '_') %>%
  mutate( plot = as.numeric( plot )) %>%
  rename( 'height' = value)

depth <- depth %>%
  rename( 'site' = plot, 'plot' = subplot) %>%
  gather( rep, depth, d1:d2) %>%
  group_by( site, plot ) %>%
  summarise( depth = mean(depth))

depth %>%
  left_join(height) %>%
  gather( type, value, depth:height) %>%
  ggplot( aes( x = plot, y = value, color = type )) +
  geom_point() +
  stat_summary(fun.y = 'mean', geom = 'line') +
  facet_wrap(~site)

# reverse order of plots in lower sites except Nebraska
depth2 <-
  depth %>%
  mutate( plot = ifelse( (site > 755) & site != 762, 6 - plot, plot ))

depth2 %>%
  left_join(height) %>%
  gather( type, value, depth:height) %>%
  ggplot( aes( x = plot, y = value, color = type )) +
  geom_point() +
  stat_summary(fun.y = 'mean', geom = 'line') +
  facet_wrap(~site)

# Save output data as site averages and plot averages
height %>%
  group_by( site ) %>%
  summarise( veg_height = mean(height), veg_height_sd = sd(height)) %>%
  write_rds('data-raw/site_veg_heights.rds')

sedgwick_veg_height <-
  height %>%
  group_by( site, plot ) %>%
  summarise( veg_height = mean(height))

usethis::use_data(sedgwick_veg_height, overwrite = T)
