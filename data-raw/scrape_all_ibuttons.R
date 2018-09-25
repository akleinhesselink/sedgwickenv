# Usage of ibutton_summarizeR.r
# Gaurav Kandlikar
# Last updated 24 Jun 2016
# This script reads in all csv sheets in a folder, cleans them up, and writes the new files into a clean files folder
# It calls on the function "scrape_raw_ibutton_file()" in the file "ibutton_summarizer.R"

# setwd("~/grad/research/dissertation/spatial_tapioca/")
source("scripts/functions/ibutton_summarizeR.R")
ibutton_file_list <- list.files("data/ibutton_data/raw/")
ibutton_file_list <- paste0("data/ibutton_data/raw/", ibutton_file_list)

for(ii in 1:length(ibutton_file_list)) {
  scrape_raw_ibutton_file(file = ibutton_file_list[ii], output_dir = "data/ibutton_data/clean/")
}


