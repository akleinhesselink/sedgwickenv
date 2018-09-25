rm(list = ls())

library(tidyverse)
library(stringr)
library(lubridate)

april_2017_weights <- read_csv('data-raw/soil_weights_2017-04-15.csv')
jan_2018_weights <- read_csv('data-raw/January_2018_soil_weights.csv')

april_2017_weights <- 
  april_2017_weights %>% 
  mutate( dry_soil_weight = dry_weight - tin - rocks, 
          wet_soil_weight = wet_weight - tin - rocks) %>% 
  mutate( water_weight = wet_soil_weight - dry_soil_weight) %>% 
  mutate( gwc = water_weight/dry_soil_weight, 
          gwc_rocks = water_weight/(dry_soil_weight + rocks) )

april_2017_weights %>% 
  ggplot( aes( x = as.factor(sample), y = gwc_rocks )) + 
  geom_point()  + 
  coord_flip()


jan_2018_weights <- 
  jan_2018_weights %>% 
  mutate( tin_weight = mean(tin_weight, na.rm = T)) %>% 
  mutate( wet_soil = wet_weight - tin_weight, 
          dry_soil = dry_weight - tin_weight, 
          water = wet_soil - dry_soil, 
          gwc = water/dry_soil )

jan_2018_weights %>% 
  ggplot(aes( x = as.factor(plot), y = gwc)) + 
  geom_point() + 
  coord_flip()

all_soil_moisture <- 
  bind_rows(
  jan_2018_weights %>% 
  select( date_collected, plot, gwc) %>% 
  filter( !str_detect(plot, 'CHEWY')) %>% 
  mutate( date_collected = mdy(date_collected)), 
  
  april_2017_weights %>% 
  mutate( plot = paste0(7, sample), 
          gwc = gwc_rocks) %>% 
  select( plot, gwc) %>% 
  mutate( date_collected = as.Date('2017-04-15')) 
  )  %>%  
  mutate( year = year(date_collected)) 

all_soil_moisture %>% 
  ggplot( aes( x = gwc, y = plot, color = as.factor(year) )) + geom_point()

all_soil_moisture %>% 
  select( year, plot, gwc ) %>% 
  group_by(year, plot) %>% 
  summarise( gwc = mean(gwc, na.rm = T)) %>% 
  spread( year, gwc) %>% 
  mutate( gwc_drop = `2018` - `2017`) %>% 
  ggplot( aes( y = plot, x = gwc_drop)) + 
  geom_point()


