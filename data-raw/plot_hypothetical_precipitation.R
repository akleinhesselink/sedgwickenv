library(ggplot2)
library(tidyverse)

mydat <- data.frame( time = 1:6, month = factor(month.abb[1:6], levels = month.abb[1:6], ordered = T)) %>% mutate( rain = c(8, 9, 7, 4, 2, 0), soil_moisture =c(0.25, 0.25, 0.2, 0.1, 0.05, 0.01))

ggplot( data= mydat, aes( x = month, y = rain ) ) + geom_bar(stat = 'identity')  + ylab('rain cm') + xlab( 'month')
ggplot( data= mydat, aes( x = month, y = soil_moisture ) ) + geom_bar(stat = 'identity')  + ylab('soil moisture (%)') + xlab( 'month')

mydat <- mydat %>% mutate(bad = c(0.25, 0.2, 0.1, 0.05, 0.00, 0.00), good = c(0.25, 0.25, 0.25, 0.2, 0.15, 0.1))

mydat <- mydat %>% 
  gather( site, soil_moisture, soil_moisture:good) %>% 
  mutate(site = factor(site, 
                       levels = c('bad', 'soil_moisture', 'good'), 
                       labels = c('dry', 'ok', 'wet'), ordered = T))

ggplot( data = mydat %>% filter( site %in% c('wet', 'dry')), aes( x = month, y = soil_moisture)) + 
  geom_bar(stat = 'identity') + 
  ylab( 'soil moisture (%)') + 
  facet_wrap(~ site)

