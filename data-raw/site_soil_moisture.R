rm(list = ls())

library(tidyverse)
library(stringr)
library(lubridate)

april_2017_weights <- read_csv('data-raw/soil_weights_2017-04-15.csv')
jan_2018_weights <- read_csv('data-raw/January_2018_soil_weights.csv')

spring_2016_soil_moisture <-
  read_csv('data-raw/environmental_data.csv') %>%
  dplyr::select( plot, starts_with('grav'), starts_with('tdr'))

april_2017_weights <-
  april_2017_weights %>%
  mutate( dry_soil_weight = dry_weight - tin - rocks,
          wet_soil_weight = wet_weight - tin - rocks) %>%
  mutate( water_weight = wet_soil_weight - dry_soil_weight) %>%
  mutate( gwc = water_weight/dry_soil_weight,
          gwc_rocks = water_weight/(dry_soil_weight + rocks) )

jan_2018_weights <-
  jan_2018_weights %>%
  mutate( tin_weight = mean(tin_weight, na.rm = T)) %>%
  mutate( wet_soil = wet_weight - tin_weight,
          dry_soil = dry_weight - tin_weight,
          water = wet_soil - dry_soil,
          gwc = water/dry_soil )

jan_2018_gwc <-
  jan_2018_weights %>%
  dplyr::select( date_collected, plot, gwc) %>%
  filter( !str_detect(plot, 'CHEWY')) %>%
  mutate( date = mdy(date_collected)) %>%
  dplyr::select(-date_collected)

april_2017_gwc <-
  april_2017_weights %>%
  mutate( plot = paste0(7, sample), gwc = gwc_rocks) %>%
  dplyr::select( plot, gwc) %>%
  mutate( date = as.Date('2017-04-15'))

new_soil_moisture <-
  bind_rows( jan_2018_gwc, april_2017_gwc )  %>%
  rename( 'site' = plot ) %>%
  mutate( site = as.numeric(site)) %>%
  group_by( site , date ) %>%
  summarise( GWC = mean( gwc, na.rm = T))

spring_2016_soil_moisture <-
  spring_2016_soil_moisture %>%
  rename( 'site' = plot ) %>%
  pivot_longer( gravimetric_water_content_by_wetmass_1apr16:TDR_3_26may16) %>%
  mutate(name = str_replace(name, 'gravimetric_water_content_by_wetmass', 'GWC_1')) %>%
  mutate(name = str_replace(name, '1ap16', '1apr16')) %>%  # typo
  separate(name, c('type', 'rep', 'date') , sep = '_') %>%
  mutate( date = lubridate::dmy(date)) %>%
  filter( type == 'GWC') %>%
  group_by(site, date ) %>%
  summarise( GWC = mean( value ))

sedgwick_soil_moisture <-
  bind_rows(new_soil_moisture,
          spring_2016_soil_moisture) %>%
  ungroup() %>%
  as.data.frame()

# Save soil moisture to add to the full environment dataframe
sedgwick_soil_moisture %>%
  mutate( month = month.abb[ month(date) ] , year = year( date ) ) %>%
  mutate( bout = paste( month, year, 'GWC', sep = '_')) %>%
  dplyr::select( -date, -month, -year ) %>%
  spread( bout, GWC ) %>%
  ungroup() %>%
  as.data.frame() %>%
  saveRDS('data-raw/site_soil_moisture.rds')

usethis::use_data(sedgwick_soil_moisture, overwrite = T)


