rm(list = ls())
library(tidyverse)
library(stringr)

soil_depth <- read_csv('data-raw/soil_depths.csv')

# Reverse plot order for some lower sites to match 2019 plot order
sedgwick_soil_depth <-
  soil_depth %>%
  rename( 'site' = 'plot',
          'plot' = 'subplot') %>%
  pivot_longer(d1:d2, 'rep', values_to = 'depth_cm') %>%
  mutate( plot = ifelse (site > 755, 6 - plot, plot )) %>%
  ungroup() %>%
  as.data.frame()

sedgwick_soil_depth %>%
  group_by( site ) %>%
  summarise( soil_depth = mean( depth_cm ), soil_depth_sd = sd ( depth_cm) )  %>%
  saveRDS( 'data-raw/site_soil_depth.rds')

usethis::use_data(sedgwick_soil_depth, overwrite = T)

