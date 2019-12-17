rm(list = ls())
library(tidyverse)

stat_weather <- read_csv('data-raw/daily_weather.csv')
fls <- dir('data-raw/2016_iButtons/clean/', '.csv$', full.names = T)
ib <- lapply(fls, read_csv)
ib_all <- do.call(rbind, ib)
ib_all$date <- as.Date( strptime( ib_all$date, '%m-%d-%y') )
ib_all$date <- as.Date( ib_all$date )

ib_daily <-
  ib_all %>%
  group_by(plot_id, date, doy) %>%
  summarise(Tmin = min(value), Tmax = max(value), n = n()) %>%
  filter( n == 12 ) %>%
  #filter( doy < 175) %>%
  mutate( range = Tmax - Tmin , Tave = (Tmin + Tmax)/2)


#
stat_weather$date <- as.Date(strptime( stat_weather$date, '%Y-%m-%d'))
stat_weather$year <- as.numeric(stat_weather$year)

stat_weather <-
  stat_weather %>%
  dplyr::select(date, doy, tmax_C, tmin_C, tavg_C)

#
ib_daily <- merge( ib_daily %>% ungroup(), stat_weather, by = c('date', 'doy'))

ib_daily <-
  ib_daily %>%
  mutate( plot_anom_Tmin = Tmin - tmin_C, plot_anom_Tmax = Tmax - tmax_C)

monthly_temps <-
  ib_daily %>%
  mutate( month = as.numeric(strftime(date, '%m'))) %>%
  group_by( month, plot_id ) %>%
  summarise( Tmax = mean(Tmax), Tmin  = mean(Tmin))

write_csv(monthly_temps, 'data-raw/monthly_plot_temps.csv')


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
  summarise( tmax_C = mean(tmax_C), tmin_C = mean(tmin_C) , Tmax_anom = mean(plot_anom_Tmax), Tmin_anom = mean(plot_anom_Tmin))

ggplot( monthly_plot_anoms, aes( x = month, y = Tmin_anom , color = factor( plot_id ) )) + geom_point() + geom_line()
ggplot( monthly_plot_anoms, aes( x = month, y = Tmax_anom , color = factor( plot_id ) )) + geom_point() + geom_line()
ggplot( monthly_plot_anoms, aes( x = Tmin_anom, y = Tmax_anom, color = factor(plot_id))) + geom_smooth(se = F, method = 'lm') + geom_point()
