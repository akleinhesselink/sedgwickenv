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
soil_depth <- readRDS('data-raw/site_soil_depth.rds')
veg_height <- readRDS('data-raw/site_veg_heights.rds')

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
  dplyr::select( -gravimetric_water_content_by_wetmass_1apr16,
                 -gravimetric_water_content_by_wetmass_26may16,
                 -TDR_1_1ap16r, -contains('TDR'))

env <-
  env %>%
  mutate(Nitrate = as.numeric( str_extract( as.character(No3_N_ppm), '[0-9]+'))) %>%
  mutate(soil_organic = as.numeric( str_extract(organic_matter_rating, '[0-9\\.]+')))

soil <-
  env %>%
  dplyr::select(site, soil_organic, pH, CEC_meq_100g, K_ppm,
                Mg_ppm, Ca_ppm, NH4_N, Nitrate, `Sand_%`, `Clay_%` ) %>%
  rename('CEC' = CEC_meq_100g, 'sand' = `Sand_%`, 'clay' = `Clay_%`) %>%
  mutate( Ca = as.numeric(str_extract(Ca_ppm, '\\d+'))) %>%
  mutate( Mg = as.numeric(str_extract(Mg_ppm, '\\d+'))) %>%
  mutate( K = as.numeric(str_extract(K_ppm, '\\d+')))

light <-
  light %>%
  rename( 'light_above' = above,
          'light_below' = below)

#  merge data ----------------------------------------------------------------------- #
df <- left_join(locs, temps )
df <- left_join(df, soil)
df <- left_join(df, hummocks)

df <-
  df %>%
  left_join(nicknames, by = 'site') %>%
  arrange( site ) %>%
  left_join(light, by = 'site') %>%
  left_join(soil_depth, by = 'site') %>%
  left_join(moisture, by = 'site') %>%
  left_join(veg_height, by = 'site') %>%
  group_by( site ) %>%
  mutate( avg_soil_moisture = (Apr_2016_GWC + Apr_2017_GWC + May_2016_GWC)/3 )

sedgwick_env <-
  df %>%
  ungroup() %>%
  dplyr::select( site, name, lon, lat, ele, name, type, microsite,
                 Tmax:avg_soil_moisture, -c(ibutton_days,contains('ppm'), date)) %>%
  as.data.frame()

usethis::use_data(sedgwick_env, overwrite = T)
