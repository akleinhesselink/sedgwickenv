library(tidyverse)
vwc <- read.csv('~/Dropbox/projects/Sedgwick_cover_data/January_2018_soil_VWC.csv')
gwc <- read.csv('~/Dropbox/projects/Sedgwick_cover_data/January_2018_soil_weights.csv')

vwc <- 
  vwc %>% 
  gather( rep, value, r1:r9) 

gwc <- 
  gwc %>% 
  mutate( tin_weight = ifelse(is.na(tin_weight), mean(tin_weight, na.rm = T), tin_weight)) %>% 
  mutate( gwc = ((wet_weight - tin_weight) - (dry_weight - tin_weight))/(dry_weight -tin_weight)) %>% 
  group_by( site, plot ) %>% 
  mutate(gwc_avg = mean(gwc, na.rm = T)) 

gwc

sm <- 
  gwc %>% 
  distinct(site, plot, gwc_avg) %>% 
  left_join(vwc, by = c('site', 'plot')) %>% 
  filter( site=='CHIPSAHOI')

sm %>% ggplot( aes( x = gwc_avg, y = value)) + geom_point()

gwc %>% ggplot( aes( x = site, y = gwc)) + geom_point()
