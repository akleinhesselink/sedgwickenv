rm(list = ls())
library(tidyverse)
library(stringr)
library(lubridate)

outfile <- 'data-raw/clean_light_data_2017-05-05.csv'

raw <- str_trim(read_lines( 'data-raw/raw_light_data_2017-05-05.txt'))
notes <- as.list(rep(NA, length(raw)))
dat <- list()

for( i in 1:length(raw)){
  print(raw[[i]])
  temp <- str_extract(raw[[i]], pattern = '(?<=Session Remark:\t).*$')

  if( i > 1 ) {
    notes[[i]] <- ifelse( is.na(temp), notes[[i-1]], temp)
  }
  dat[[i]] <- str_extract(raw[[i]], pattern = '(?<=DATA\t).*$')
}

id <- notes[which(!is.na(dat))]
dat <- dat[which(!is.na(dat))]

light <-
  data.frame( id = do.call(rbind, id), data = do.call(rbind, dat)) %>%
  separate(data, c('V1', 'date', 'time', 'value', 'V2', 'V3'), sep = '\t') %>%
  mutate( value =  as.numeric(value)) %>%
  mutate( time = str_remove(time, '\\.[0-9]+$')) %>%
  unite(date, c('date', 'time'), date, sep = ' ') %>%
  mutate( date = as_datetime(date)) %>%
  dplyr::select( id, date, value) %>%
  separate(id, c('site', 'notes'), sep = '-')  %>%
  group_by(site, notes) %>%
  mutate( position = ifelse(row_number() %% 2 == 0, 'below', 'above'))


# Some data edits

light <-
  light %>%
  ungroup() %>%
  mutate( position = ifelse( site == '741' & value < 1000 ,
                             'below',
                             position )) %>%
  mutate( site = ifelse( site == '752' & is.na(notes), '753', site )) %>%
  mutate( site = ifelse( site == 'NEB', '762', site)) %>%
  mutate( site = ifelse( site == '750' & date > '2017-05-05', '760', site)) %>%
  mutate( site = ifelse( site == '751' & date > '2017-05-05', '761', site)) %>%
  filter( !(site == 759 & !is.na(notes)),
          !(site == 762 & is.na(notes)))

light <-
  light %>%
  arrange(date) %>%
  rename( 'datetime' = date) %>%
  mutate( date = date(datetime)) %>%
  group_by( site, date, position) %>%
  summarise(value = mean(value)) %>%
  spread( position, value) %>%
  mutate( light_use = (above - below)/above)


light %>%
  ggplot( aes( x = site, y = light_use)) +
  geom_point()

light %>%
  ggplot( aes( x = site , y = above)) +
  geom_point()

light %>%
  ggplot( aes( x = site, y= below)) +
  geom_point()


write_csv(light, outfile)
