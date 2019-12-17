rm(list = ls())
library(tidyverse)
library(stringr)

outfile <- 'data-raw/all_environmental_data.csv'

nicknames <- read_csv('data-raw/site_nicknames.csv')
hummocks <- read_csv('data-raw/hummock.csv')
env <- read_csv('data-raw/environmental_data.csv')
locs <- read_csv('data-raw/plot_locations.csv')
light <- read_csv('data-raw/clean_light_data_2017-05-05.csv')
moisture <- readRDS('data-raw/site_soil_moisture.rds')
temps <- readRDS('data-raw/monthly_plot_temps.rds')
soil_depth <- readRDS('data-raw/plot_soil_depths.rds')

locs$type <- NA
locs$type[ locs$name < 756 ] <- 'upper'
locs$type[ locs$name >=756 ] <- 'lower'

# pre-process data ------------------------------------------------------------------ #
temps <-
  temps %>%
  filter( month %in% c(3) )

locs <-
  locs %>%
  rename( 'site' = name ) %>%
  dplyr::select( site, lat , lon, ele, type )

env <-
  env %>%
  mutate( 'site' = plot) %>%
  group_by(site) %>%
  mutate( soil_moisture = mean(gravimetric_water_content_by_wetmass_1apr16, gravimetric_water_content_by_wetmass_26may16)) %>%
  dplyr::select( -gravimetric_water_content_by_wetmass_1apr16, -gravimetric_water_content_by_wetmass_26may16, -TDR_1_1ap16r, -contains('TDR'))

env <-
  env %>%
  mutate(Nitrate_ppm = as.numeric( str_extract( as.character(No3_N_ppm), '[0-9]+')))

soil <-
  env %>%
  dplyr::select(site, organic_matter_ENR, pH, CEC_meq_100g, K_ppm, Mg_ppm, Ca_ppm, NH4_N, Nitrate_ppm, soil_moisture, `Sand_%`, `Clay_%` ) %>%
  mutate( Ca_ppm = as.numeric(str_extract(Ca_ppm, '\\d+'))) %>%
  mutate( Mg_ppm = as.numeric(str_extract(Mg_ppm, '\\d+'))) %>%
  mutate( K_ppm = as.numeric(str_extract(K_ppm, '\\d+')))

light <-
  light %>%
  rename( 'light_above' = above,
          'light_below' = below)


site_soil_depth <-
  soil_depth %>%
  group_by( site ) %>%
  summarise( soil_depth_cm = mean(depth_cm), soil_depth_sd = sd( depth_cm ))


#  merge data ----------------------------------------------------------------------- #
df <- left_join(locs, temps )
df <- left_join(df, soil)
df <- left_join(df, hummocks)

df <-
  df %>%
  left_join(nicknames, by = 'site') %>%
  arrange( site ) %>%
  left_join(light, by = 'site') %>%
  left_join(site_soil_depth, by = 'site') %>%
  left_join(moisture, by = 'site')

sedgwick_env <-
  df %>%
  dplyr::select( site, lon, lat, ele, name, type, microsite, Tmax:`Clay_%`, Jan_2018_GWC, Apr_2016_GWC, Apr_2017_GWC, May_2016_GWC, soil_depth_cm, soil_depth_sd, light_above, light_below, light_use)

usethis::use_data(sedgwick_env, overwrite = T)
