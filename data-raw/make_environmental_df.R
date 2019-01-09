rm(list = ls())
library(tidyverse)
library(stringr)

outfile <- 'data-raw/all_environmental_data.csv'

soil_depth <- read_csv('data-raw/soil_depths.csv')
hummocks <- read_csv('data-raw/hummock.csv')
env <- read_csv('data-raw/environmental_data.csv')
temps <- read_csv('data-raw/monthly_plot_temps.csv')
locs <- read_csv('data-raw/plot_locations.csv')
light <- read_csv('data-raw/clean_light_data_2017-05-05.csv')

locs$type <- NA
locs$type[ locs$name < 756 ] <- 'upper'
locs$type[ locs$name >=756 ] <- 'lower'

# pre-process data ------------------------------------------------------------------ #

subplot_depths <-
  soil_depth %>%
  gather( rep, depth,  d1, d2 ) %>%
  mutate( depth = ifelse (depth > 40, 45, depth ) ) %>%
  group_by( plot, subplot ) %>%
  summarise ( depth = mean(depth))

plot_depths <-
  subplot_depths %>%
  group_by( plot ) %>%
  summarise( depth = mean(depth ))

temps <-
  temps %>%
  rename( plot = plot_id) %>%
  filter( month %in% c(3) ) %>%
  group_by( plot) %>%
  summarise( Tmax = mean(Tmax), Tmin = mean(Tmin))

locs <-
  locs %>%
  rename( plot= name ) %>%
  select( plot, lat , lon, ele, type )

env <-
  env %>%
  group_by(plot) %>%
  mutate( soil_moisture = mean(gravimetric_water_content_by_wetmass_1apr16, gravimetric_water_content_by_wetmass_26may16)) %>%
  select( -gravimetric_water_content_by_wetmass_1apr16, -gravimetric_water_content_by_wetmass_26may16, -TDR_1_1ap16r, -contains('TDR'))

env <-
  env %>%
  mutate(Nitrate_ppm = as.numeric( str_extract( as.character(No3_N_ppm), '[0-9]+')))

soil <-
  env %>%
  select(plot, organic_matter_ENR, pH, CEC_meq_100g, K_ppm, Mg_ppm, Ca_ppm, NH4_N, Nitrate_ppm, soil_moisture, `Sand_%`, `Clay_%` ) %>%
  mutate( Ca_ppm = as.numeric(str_extract(Ca_ppm, '\\d+'))) %>%
  mutate( Mg_ppm = as.numeric(str_extract(Mg_ppm, '\\d+'))) %>%
  mutate( K_ppm = as.numeric(str_extract(K_ppm, '\\d+')))

#  merge data ----------------------------------------------------------------------- #
df <- left_join(locs, temps )

plot( df$ele, df$Tmax)
plot( df$ele, df$Tmin)

df <- left_join(df, soil)
plot(df$ele, df$soil_moisture)
plot(df$Tmax, df$soil_moisture)
plot(df$Tmin, df$soil_moisture)

df <- left_join(df, hummocks)

df <- left_join( df, plot_depths)

light <-
  light %>%
  rename( 'light_above' = above,
          'light_below' = below)

df <-
  df %>%
  rename('site' = plot)

sedgwickenv <- left_join(df, light, by = 'site')

devtools::use_data(sedgwickenv, overwrite = T)
