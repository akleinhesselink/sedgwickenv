# Function to scrape and reformat data from IButtons
# Gaurav Kandlikar, gkandlikar
# Last updated 2 Feb 2016

require(stringr); require(dplyr)
scrape_raw_ibutton_file <- function(file, output_dir) {
  to_write <- read.table(file, skip = 14, header = T, sep = ",")
  formatted_timestamp <- stringr::str_split_fixed(to_write$Date.Time, pattern = " ", n = 3)
  colnames(formatted_timestamp) <- c("date", "time", "am_pm")
  formatted_timestamp[, "date"] <- str_replace_all(formatted_timestamp[, "date"], "/", "-")
  doy <- strftime(as.Date(formatted_timestamp[,"date"], "%m-%d-%y"), format = "%j")
  formatted_timestamp <- cbind(doy, formatted_timestamp)
  # insert a thing to split time column into three columns
  to_write <- to_write %>% select(-Date.Time)
  to_write <- cbind(formatted_timestamp, to_write)
  colnames(to_write) <- tolower(colnames(to_write))
  con <- file(file,open="r")
  on.exit(close(con))
  ibutton_id <- readLines(con)[2]
  ibutton_id <- stringr::str_split(ibutton_id, pattern = " ")[[1]][4]
  ibutton_id <- rep(ibutton_id, nrow(to_write))
  plot_id <- str_split(file, "/")[[1]][4] %>% substr(., 6, 8)
  plot_id <- rep(plot_id, nrow(to_write))
  to_write <- cbind(ibutton_id, to_write)
  to_write <- cbind(plot_id, to_write )
  write.csv(x = to_write, file = paste0(output_dir, ibutton_id[1], ".csv"), 
            quote = F, row.names = F)
}
