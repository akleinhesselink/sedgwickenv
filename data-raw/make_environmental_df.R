library(stringr)
library(dplyr)
library ( tidyr)
# make environmental dataframe 

soil_depth <- read.csv('~/Dropbox/Sedgwick/plot_data/soil_depths.csv')
hummock <- read.csv('~/Dropbox/Sedgwick/plot_data/hummock.csv')

env <- read.csv('~/Dropbox/Sedgwick/spatial_tapioca/data/environmental/environmental_data.csv')

temps <- read.csv('~/Dropbox/Sedgwick/spatial_tapioca/data/environmental/monthly_plot_temps.csv')

locs <- read.csv('~/Dropbox/Sedgwick/spatial_tapioca/data/environmental/plot_locations.csv')

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

write.csv(subplot_depths, '~/Dropbox/Sedgwick/spatial_tapioca/data/environmental/subplot_depths.csv', row.names = F)

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

temps

locs <- 
  locs %>% 
  rename( plot= name ) %>% 
  select( plot, lat , lon, ele, type )


env <- 
  env %>% 
  group_by(plot) %>% 
  mutate( soil_moisture = mean(gravimetric_water_content_by_wetmass_1apr16, gravimetric_water_content_by_wetmass_26may16)) %>% 
  select( -gravimetric_water_content_by_wetmass_1apr16, -gravimetric_water_content_by_wetmass_26may16, -TDR_1_1ap16r, -contains('TDR'))

env <- env %>% mutate(Nitrate_ppm = as.numeric( str_extract( as.character(No3_N_ppm), '[0-9]+')))

soil <- 
  env %>% 
  select(plot, organic_matter_ENR, pH, CEC_meq_100g, K_., Mg_., Ca_., NH4_N, Nitrate_ppm, soil_moisture, Sand_., Clay_.  )

#  merge data ----------------------------------------------------------------------- # 
df <- left_join(locs, temps )
plot( df$ele, df$Tmax)
plot( df$ele, df$Tmin)

df <- left_join(df, soil)
plot(df$ele, df$soil_moisture)
plot(df$Tmax, df$soil_moisture)
plot(df$Tmin, df$soil_moisture)

df <- left_join(df, hummock)

df <- left_join( df, plot_depths)
write.csv(df, '~/Dropbox/Sedgwick/spatial_tapioca/data/environmental/all_environmental_data.csv', row.names = F)
