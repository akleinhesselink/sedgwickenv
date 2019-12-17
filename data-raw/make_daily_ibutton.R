rm(list = ls())
library(tidyverse)
library(lubridate)

stat_weather <- read_csv('data-raw/daily_weather.csv')
record <- read_csv('data-raw/2018_iButtons/2018_iButton_record.csv')

fls <- dir('data-raw/2018_iButtons/clean/', '.csv$', full.names = T)

ib_2018 <-
  lapply(fls, read_csv) %>%
  do.call(rbind, .) %>%
  mutate( date = mdy(date )) %>%
  rename( 'iButton' = plot_id) %>%
  left_join(record ) %>%
  dplyr::select( -iButton, -retrieved) %>%
  group_by(site, date, doy) %>%
  summarise(Tmin = min(value), Tmax = max(value), n = n()) %>%
  filter( n == 12 ) %>%
  filter( as.numeric(doy) < 175) %>%
  mutate( daily_range = Tmax - Tmin , Tavg = (Tmin + Tmax)/2)

# ------- 2016 ------------------- #
fls <- dir('data-raw/2016_iButtons/clean/', '.csv$', full.names = T)

ib_2016 <-
  lapply(fls, read_csv) %>%
  do.call(rbind, . ) %>%
  mutate( date = mdy(date )) %>%
  rename( 'site' = plot_id) %>%
  group_by(site, date, doy) %>%
  summarise(Tmin = min(value), Tmax = max(value), n = n()) %>%
  filter( n == 12 ) %>%
  mutate( daily_range = Tmax - Tmin , Tavg = (Tmin + Tmax)/2)

# ------------- bind together ------- #
ibutton <-
  ib_2016 %>%
  bind_rows(ib_2018) %>%
    dplyr::select(site, date, doy, Tmin, Tmax, Tavg, daily_range)

usethis::use_data(ibutton, overwrite = T)

# ------- save monthly averages env dataframe ----- #

ibutton %>%
  mutate( month = month(date), year = year(date)) %>%
  group_by( site, month) %>%
  summarise( Tmax = mean(Tmax), Tmin  = mean(Tmin), ibutton_days = n())  %>%
  saveRDS('data-raw/monthly_plot_temps.rds')




