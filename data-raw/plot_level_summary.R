file_list <- list()
file_names <- list.files("data/environmental/ibutton_data/clean/")
for(ii in length(file_names)) {
  file_list[[ii]] <- read.csv(paste0("data/environmental/ibutton_data/clean/", file_names[ii]))
}
