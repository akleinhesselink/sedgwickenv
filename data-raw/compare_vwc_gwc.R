library(tidyverse)
vwc <- read.csv('data-raw/January_2018_soil_VWC.csv')
gwc <- read.csv('data-raw/January_2018_soil_weights.csv')

vwc <-
  vwc %>%
  gather( rep, value, r1:r9)

vwc <-
  vwc %>%
  filter( complete.cases(.))

gwc <-
  gwc %>%
  mutate( tin_weight = mean(tin_weight, na.rm = T)) %>%
  filter( complete.cases(.)) %>%
  mutate( dry_soil = dry_weight - tin_weight,
          wet_soil = wet_weight - tin_weight,
          water = wet_soil - dry_soil,
          gwc = water/dry_soil) %>%
  group_by(site, plot ) %>%
  summarise( gwc = mean(gwc))

sm <-
  gwc %>%
  left_join(vwc, by = c('site', 'plot')) %>%
  filter( site=='CHIPSAHOI')

sm %>% ggplot( aes( x = gwc, y = value)) + geom_point()

gwc %>% ggplot( aes( x = site, y = gwc)) + geom_point()
