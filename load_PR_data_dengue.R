#SV Scarpino
#July 2018
#PDF to CSV for Puerto Rico DoH dengue data (2013 - 2016)

#set working dir
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))#sets working directory to source file location

#libraries (not included in limits_acc_functions.R)
library(pdftools)

#########
#Globals#
#########
download_new_dengue <- FALSE #set to TRUE to download files
write_new <- FALSE #set to TRUE to save a new csv
dengue_path <- "Raw PDFs/dengue/"
base_file_main <- "http://www.salud.gov.pr/Estadisticas-Registros-y-Publicaciones/Estadisticas%20Dengue/Informe%20y%20Tabla%20Semana%20"
base_file_13 <- "http://www.salud.gov.pr/Estadisticas-Registros-y-Publicaciones/Estadisticas%20Dengue/Informe%20Dengue%20Semana%20"
time_stamp <- as.numeric(Sys.time())

###########
#acc funcs#
###########
parse_dengue <- function(filename, week, path){
  data <- pdf_text(paste0(path, filename))
  data_split <- strsplit(data, "\n")
  
  #Semana
  semana_loc <- grep(paste0("Semana ",week), data_split[[1]])
  semana_raw <- data_split[[1]][semana_loc[2]]
  
  semana_no_em <- gsub(pattern = "\u2014", replacement = "-", semana_raw)
  
  semana_no_space <- gsub(pattern = "- ", replacement = "-", semana_no_em)
  semana_no_space <- gsub(pattern = " -", replacement = "-", semana_no_space)
  semana_no_space <- gsub(pattern = " - ", replacement = "-", semana_no_space)
  
  semana_split <- strsplit(x = semana_no_space, split = " ")
  semana_comma <- paste0(unlist(semana_split)[2:3], collapse = " ")
  semana <- gsub(pattern = ",", replacement = "", semana_comma)
  
  #suspected cases
  data_split[[1]] <- gsub(pattern = "presuntos", replacement = "sospechosos", data_split[[1]])
  data_split[[1]] <- gsub(pattern = "reportes", replacement = "sospechosos", data_split[[1]])
  data_split[[1]] <- gsub(pattern = "caso sospechosos", replacement = "casos sospechosos", data_split[[1]])
  
  suspected_loc <- grep("sospechosos", data_split[[1]])
  suspected_raw <- data_split[[1]][suspected_loc[2]]
  suspected <- strsplit(x = suspected_raw, split = " ")[[1]][2]
  suspected <- gsub(pattern = ",", "", suspected)
  suspected <- as.numeric(suspected)
  
  #confirmed cases
  confirmed_loc <- grep("fueron confirmados", data_split[[1]])
  confirmed_raw <- data_split[[1]][confirmed_loc[1]]
  confirmed_split <- strsplit(x = confirmed_raw, split = "[(]")[[1]][1]
  confirmed_split <- gsub(pattern = " ", replacement = "", x = confirmed_split)
  if(length(confirmed_split) == 0|is.na(confirmed_split)==TRUE){
    confirmed_split <- NA
  }else{
    if(confirmed_split == "--"){
      confirmed_split <- 0
    }
  }
  confirmed_split <- gsub(pattern = ",", "", confirmed_split)
  confirmed_numb <- as.numeric(confirmed_split)
  
  return(list("Semana" = semana, "Suspected" = suspected, "Confirmed" = confirmed_numb))
}

###########
#Data Sets#
###########
#1. Download dengue

if(download_new_dengue == TRUE){
  #Download data
  years <- c(2013,2014,2015,2016)

  missed <- c()
  for(i in years){
    for(j in 1:54){
      if(i == 2013){
        base_file <- base_file_13
      }else{
        base_file <- base_file_main
      }
      if(i == 2014 & nchar(j) == 1){
        j <- paste0("0",j)
      }
      if(i == 2015 & nchar(j) == 1){
        j <- paste0("0",j)
      }
      loc.file.ij <- paste0(base_file, j, "-", i, ".pdf")
      dest.file.ij <- strsplit(x = loc.file.ij, split = "/")
      dest.file.ij <- dest.file.ij[[1]][6]
      try_ij <- try(download.file(url = loc.file.ij, destfile = paste0(dengue_path, dest.file.ij)), silent = TRUE)
      if(length(grep("error", try_ij, ignore.case = TRUE)) > 0){
        missed <- c(missed, dest.file.ij)
      }
    }
  }
}

#2. Extract data from PDFs
dengue_files <- list.files("Raw PDFs/dengue/")

data <- matrix(NA, ncol = 5, nrow = length(dengue_files))
colnames(data) <- c("Year", "Week", "Group", "Confirmed", "Suspected")
data <- as.data.frame(data)
for(i in 1:length(dengue_files)){
  file_name.i <- dengue_files[i]
  year.i <- substr(x = file_name.i, start = nchar(file_name.i)-7, stop = nchar(file_name.i)-4)
  if(year.i == 2013){
    base_file <- base_file_13
  }else{
    base_file <- base_file_main
  }
  week.i <- strsplit(x = file_name.i, split = "%20")[[1]][4]
  week.i <- strsplit(x = week.i, split = "-")[[1]][1]
  
  parsed.i <- parse_dengue(filename = file_name.i, week = week.i, path = dengue_path)
  
  data$Year[i] <- year.i
  data$Week[i] <- week.i
  data$Group[i] <- parsed.i$Semana
  data$Suspected[i] <- parsed.i$Suspected
  data$Confirmed[i] <- parsed.i$Confirmed
}

#3. Order data set
data_order <- c()
years_var <- as.numeric(unique(data$Year))
years_var <- years_var[order(years_var, decreasing = FALSE)]

for(i in years_var){
  use.i <- which(data$Year == i)
  order_i <- order(as.numeric(data$Week)[use.i])
  data_order <- c(data_order, use.i[order_i])
}
data_out <- data[data_order, ]

#4. Population sizes
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

#5. Save
if(write_new == TRUE){
  filename <- paste0("Data/dengue_pops_", time_stamp,"-years-", paste0(years_var, collapse = "-"), ".csv")
  write.csv(x = data_out, file = filename, row.names = FALSE, quote = FALSE)
}
