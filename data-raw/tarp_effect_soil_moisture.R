rm(list = ls())

library(ggplot2)
library(tidyr)
library(dplyr)

df <- read.csv('data-raw/soil_moisture_candi_cage_5-5-2017.csv')

df <- df %>% mutate( water_content = (wet_weight_with_tin - dry_weight_with_tin)/(dry_weight_with_tin - tin_weight) )

plot(df$water_content)
ggplot(df, aes( x = depth, y = water_content, color = bare)) + 
  geom_point(size = 3) +
  facet_wrap(~tarped_area)

ggplot ( df %>% group_by(tarped_area, bare, depth) %>% 
           summarise(wc = mean(water_content)), aes( x = depth, y = wc, color = bare ))  + 
  geom_point() + 
  facet_wrap(~tarped_area) 
