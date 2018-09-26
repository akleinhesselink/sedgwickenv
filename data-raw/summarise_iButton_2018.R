rm(list = ls())
library(tidyverse)

stat_weather <- read_csv('data-raw/daily_weather_2015_to_2016.csv')
record <- read_csv('data-raw/2018_iButtons/2018_iButton_record.csv')

fls <- dir('data-raw/2018_iButtons/clean/', '.csv$', full.names = T)

ib <- lapply(fls, read_csv)

ib_all <- do.call(rbind, ib)

ib_all$date <- as.Date( strptime( ib_all$date, '%m-%d-%y') )

ib_all$date <- as.Date( ib_all$date )

ib_all <-
  ib_all %>%
  rename( 'iButton' = plot_id) %>%
  left_join(record ) %>%
  select( -iButton, -retrieved)


ib_daily <-
  ib_all %>%
  group_by(plot_id, date, doy) %>%
  summarise(Tmin = min(value), Tmax = max(value), n = n()) %>%
  filter( n == 12 ) %>%
  filter( doy < 175) %>%
  mutate( range = Tmax - Tmin , Tave = (Tmin + Tmax)/2)

#

stat_weather$date <- as.Date(strptime( stat_weather$date, '%m/%d/%y'))
stat_weather$year <- as.numeric(stat_weather$year)

stat_weather[ stat_weather == -9999.0 ] <- NA

stat_weather <-
  stat_weather %>%
  rename(solar_rad = `solar rad kW-hr/m2`, Tmax_stat = `air temp max deg. C`, Tmin_stat = `air temp min deg. C`, Tave_stat = `air temp ave. deg. C`) %>%
  select(date, doy, solar_rad, Tmax_stat, Tmin_stat, Tave_stat)

#
ib_daily <- merge( ib_daily %>% ungroup(), stat_weather, by = c('date', 'doy'))

ib_daily <-
  ib_daily %>%
  mutate( plot_anom_Tmin = Tmin - Tmin_stat, plot_anom_Tmax = Tmax - Tmax_stat)

monthly_temps <-
  ib_daily %>%
  mutate( month = as.numeric(strftime(date, '%m'))) %>%
  group_by( month, plot_id ) %>%
  summarise( Tmax = mean(Tmax), Tmin  = mean(Tmin))

#write_csv(monthly_temps, 'data-raw/monthly_plot_temps.csv')

ggplot(ib_daily, aes( x = date, y = plot_anom_Tmin, color = factor(plot_id))) +
  geom_line() +
  facet_wrap(~plot_id)

ggplot(ib_daily, aes( x = date, y = plot_anom_Tmax, color = factor(plot_id))) +
  geom_line() +
  facet_wrap(~plot_id)

monthly_plot_anoms <-
  ib_daily %>%
  mutate( month = as.numeric( strftime(date , '%m') )) %>%
  group_by(plot_id, month) %>%
  summarise( Tmax_stat = mean(Tmax_stat), Tmin_stat = mean(Tmin_stat) , Tmax_anom = mean(plot_anom_Tmax), Tmin_anom = mean(plot_anom_Tmin))

ggplot( monthly_plot_anoms, aes( x = month, y = Tmin_anom , color = factor( plot_id ) )) + geom_point() + geom_line()
ggplot( monthly_plot_anoms, aes( x = month, y = Tmax_anom , color = factor( plot_id ) )) + geom_point() + geom_line()
ggplot( monthly_plot_anoms, aes( x = Tmin_anom, y = Tmax_anom, color = factor(plot_id))) + geom_smooth(se = F, method = 'lm') + geom_point()
