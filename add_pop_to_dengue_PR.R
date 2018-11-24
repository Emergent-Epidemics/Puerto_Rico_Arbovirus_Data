#SV Scarpino
#Nov 2018
#Add population sizes to dengue data set

#set working dir
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))#sets working directory to source file location

#libraries (not included in limits_acc_functions.R)

#########
#Globals#
#########
write_new <- FALSE #set to TRUE to save a new csv
time_stamp <- as.numeric(Sys.time())

###########
#acc funcs#
###########

###########
#Data Sets#
###########
#1. Load PR dengue data
data_out <- read.csv("Data/san_juan_dengue_data.csv")

data_out$Year <- substr(data_out$week_start_date, 1, 4)

#2. Population sizes
#from https://en.wikipedia.org/wiki/Demographics_of_Puerto_Rico
# B.R. Mitchell. International historical statistics: the Americas, 1750–2000
# "United Nations Statistics Division – Demographic and Social Statistics". Unstats.un.org. Retrieved 14 October 2017.
# "Archived copy". Archived from the original on 2017-09-27. Retrieved 2017-09-09.
#"Archived copy" (PDF). Archived from the original (PDF) on 2017-10-16. Retrieved 2017-10-03.
pop_size_pr <- read.table("PR_pop_size.txt", sep = "\t", header = TRUE, stringsAsFactors = FALSE)

years <- unique(data_out$Year)
use_pops <- which(pop_size_pr$Year %in% years)
pops <- pop_size_pr$Averagepopulation.x1000.[use_pops]*1000
tab_years <- table(data_out$Year)
data_out$population_est <- rep(pops, tab_years)

#3. Save
if(write_new == TRUE){
  years_var <- as.numeric(unique(data_out$Year))
  years_var <- years_var[order(years_var, decreasing = FALSE)]
  filename <- paste0("Data/san_juan_dengue_data_pop_", time_stamp,"-years-", paste0(years_var, collapse = "-"), ".csv")
  write.csv(x = data_out, file = filename, row.names = FALSE, quote = FALSE)
}