rm(list = ls())
library(tidyverse)
library(stringr)

# station data downloaded from: https://wrcc.dri.edu/cgi-bin/rawMAIN.pl?caucse

outfile <- 'data-raw/daily_weather.csv'
field_names <- c('date', 'year', 'doy', 'dor', 'solar_kW-hr/m2', 'wind_speed_m/s', 'wind_dir_deg.', 'speed_gust_m/s', 'tavg_C', 'tmax_C', 'tmin_C', 'RH_avg', 'RH_max', 'RH_min', 'Penman_ET_mm', 'growing_deg_days_40', 'growing_deg_days_50', 'soil_moisture_avg', 'soil_moisture_max', 'soil_moisture_min', 'precip_mm')

weather <- read_lines('data-raw/daily_weather_2016_to_2018.txt', skip = 6)
weather <- do.call( rbind, str_split(str_trim(weather), '\\s+') )
weather <- as.data.frame(weather, stringsAsFactors = F)

dates <- weather$V1
weather <- do.call(cbind, lapply( weather[, -1], function(x) as.numeric(x) ))
weather <- data.frame(date = dates, weather )
names(weather) <-  field_names
weather[ weather == -9999 ]  <- NA

weather <-
  weather %>%
  mutate( date = as.Date(date, '%m/%d/%Y'))

weather %>%
  ggplot( aes( x = date, y = Penman_ET_mm)) +
  geom_line()

weather %>%
  ggplot( aes( x = date, y = soil_moisture_avg)) +
  geom_line() +
  scale_x_date(date_breaks = '2 month', date_labels = c('%b'))

weather %>%
  group_by(year) %>%
  mutate( cm_gdd50 = cumsum(growing_deg_days_50) ) %>%
  ggplot( aes( x = doy, y = cm_gdd50, color = factor(year) )) +
  geom_line()

weather %>%
  group_by( year ) %>%
  mutate( cm_precip = cumsum(precip_mm)) %>%
  ggplot( aes( x = doy, y = cm_precip, color = factor(year))) +
  geom_line()

weather <-
  weather %>%
  mutate( doy = str_pad(doy, width = 3, side = 'left', pad = '0'))

write_csv(weather, outfile)
