rm(list = ls())
library(tidyverse)
library(stringr)

soil_depth <- read_csv('data-raw/soil_depths.csv')


# Reverse plot order for some lower sites to match 2019 plot order

soil_depth <-
  soil_depth %>%
  rename( 'site' = 'plot',
          'plot' = 'subplot') %>%
  pivot_longer(d1:d2, 'rep', values_to = 'depth_cm')

soil_depth %>%
  ggplot( aes( x = plot, y = depth_cm )) +
  geom_point() +
  stat_summary(geom = 'line', fun.y =  'mean') +
  facet_wrap(~ site, scales = 'free_y')

soil_depths_mod <-
  soil_depth %>%
  mutate( plot = ifelse (site > 755, 6 - plot, plot ))


soil_depths_mod %>%
  saveRDS('data-raw/plot_soil_depths.rds')


usethis::use_data(soil_depth, overwrite = T)

