#SV Scarpino
#July 2018
#PDF to CSV for Puerto Rico DoH chikungunya data (2013 - 2016)

#set working dir
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))#sets working directory to source file location

#libraries (not included in limits_acc_functions.R)
library(pdftools)

#########
#Globals#
#########
download_new_chikungunya <- FALSE #set to TRUE to download files
write_new <- FALSE #set to TRUE to save a new csv
chikungunya_path <- "Raw PDFs/chikungunya/"
time_stamp <- as.numeric(Sys.time())

###########
#acc funcs#
###########
parse_chikungunya <- function(filename, path){
  data <- pdf_text(paste0(path, filename))
  data_split <- strsplit(data, "\n")
  
  #Semana
  semana_loc <- grep("Semana", data_split[[1]])
  semana_raw <- data_split[[1]][semana_loc[3]]
  
  semana_no_em <- gsub(pattern = "\u2014", replacement = "-", semana_raw)
  
  semana_no_space <- gsub(pattern = "- ", replacement = "-", semana_no_em)
  semana_no_space <- gsub(pattern = " -", replacement = "-", semana_no_space)
  semana_no_space <- gsub(pattern = " - ", replacement = "-", semana_no_space)
  
  semana_split <- strsplit(x = semana_no_space, split = " ")
  semana_comma <- paste0(unlist(semana_split)[1:2], collapse = " ")
  semana <- gsub(pattern = ",", replacement = "", semana_comma)
  
  #suspected cases
  data_split[[1]] <- gsub(pattern = "presuntos", replacement = "sospechosos", data_split[[1]])
  data_split[[1]] <- gsub(pattern = "reportes", replacement = "sospechosos", data_split[[1]])
  data_split[[1]] <- gsub(pattern = "caso sospechosos", replacement = "casos sospechosos", data_split[[1]])
  
  suspected_loc <- grep("casos sospechosos", data_split[[1]])
  suspected_raw <- data_split[[1]][suspected_loc[1]]
  suspected <- strsplit(x = suspected_raw, split = " ")[[1]][1]
  suspected <- gsub(pattern = ",", "", suspected)
  suspected <- as.numeric(suspected)
  
  #confirmed cases
  data_split[[1]] <- gsub(pattern = "conﬁrmados", replacement = "confirmados", data_split[[1]])
  data_split[[1]] <- gsub(pattern = "caso confirmado", replacement = "casos confirmados", data_split[[1]])
  data_split[[1]] <- gsub(pattern = "caso conﬁrmado", replacement = "casos confirmados", data_split[[1]])
  confirmed_loc <- grep("casos confirmados", data_split[[1]])
  confirmed_raw <- data_split[[1]][confirmed_loc[1]]
  confirmed_split <- strsplit(x = confirmed_raw, split = " casos confirmados")[[1]][1]
  if(confirmed_split == "--"){
    confirmed_split <- 0
  }
  confirmed_split <- gsub(pattern = ",", "", confirmed_split)
  confirmed_numb <- as.numeric(confirmed_split)
  
  #confinfected cases
  coinf_loc <- grep("co-infección", data_split[[1]])
  coinf_loc_raw <- data_split[[1]][coinf_loc[1]]
  coinf_loc_raw_numb <- strsplit(x = coinf_loc_raw, split = " ")[[1]][1]
  coinf_loc_raw_numb <- gsub(pattern = ",", "", coinf_loc_raw_numb)
  coinf_numb <- as.numeric(coinf_loc_raw_numb)
  
  return(list("Semana" = semana, "Suspected" = suspected, "Confirmed" = confirmed_numb, "CoInfDenChi" = coinf_numb))
}

###########
#Data Sets#
###########
#1. Download chikungunya

if(download_new_chikungunya == TRUE){
  #Download data
  years <- c(2014,2015,2016)
  base_file <- "http://www.salud.gov.pr/Estadisticas-Registros-y-Publicaciones/Estadisticas%20Chikungunya/Reporte%20ChikV%20Semana%20"
  
  missed <- c()
  for(i in years){
    for(j in 1:54){
      if(i == 2015 & nchar(j) == 1){
        j <- paste0("0",j)
      }
      loc.file.ij <- paste0(base_file, j, "-", i, ".pdf")
      dest.file.ij <- strsplit(x = loc.file.ij, split = "/")
      dest.file.ij <- dest.file.ij[[1]][6]
      try_ij <- try(download.file(url = loc.file.ij, destfile = paste0(chikungunya_path, dest.file.ij)), silent = TRUE)
      if(length(grep("error", try_ij, ignore.case = TRUE)) > 0){
        missed <- c(missed, dest.file.ij)
      }
    }
  }
  #two files with weird naming conventions
  loc.file.ij <- "http://www.salud.gov.pr/Estadisticas-Registros-y-Publicaciones/Estadisticas%20Chikungunya/Reporte%20ChikV%20Semana%2022-2013.pdf"
  dest.file.ij <- "Reporte%20ChikV%20Semana%2022-2014.pdf" #they had the wrong year there
  try_ij <- try(download.file(url = loc.file.ij, destfile = paste0(chikungunya_path, dest.file.ij)), silent = TRUE)
  if(length(grep("error", try_ij, ignore.case = TRUE)) > 0){
    stop("Couldn't find file")
  }
  
  loc.file.ij <- "http://www.salud.gov.pr/Estadisticas-Registros-y-Publicaciones/Estadisticas%20Chikungunya/Reporte%20ChikV%20Semana%2052-03%202015.pdf"
  dest.file.ij <- strsplit(x = loc.file.ij, split = "/")
  dest.file.ij <- dest.file.ij[[1]][6]
  try_ij <- try(download.file(url = loc.file.ij, destfile = paste0(chikungunya_path, dest.file.ij)), silent = TRUE)
  if(length(grep("error", try_ij, ignore.case = TRUE)) > 0){
    stop("Couldn't find file")
  }
}

#2. Extract data from PDFs
chikungunya_files <- list.files("Raw PDFs/chikungunya/")

data <- matrix(NA, ncol = 6, nrow = length(chikungunya_files))
colnames(data) <- c("Year", "Week", "Group", "Confirmed", "Suspected", "CoInf_DENV_CHIKV")
data <- as.data.frame(data)

for(i in 1:length(chikungunya_files)){
  file_name.i <- chikungunya_files[i]
  year.i <- substr(x = file_name.i, start = nchar(file_name.i)-7, stop = nchar(file_name.i)-4)
  week.i <- strsplit(x = file_name.i, split = "%20")[[1]][4]
  week.i <- strsplit(x = week.i, split = "-")[[1]][1]
  
  parsed.i <- parse_chikungunya(filename = file_name.i, path = chikungunya_path)
  
  data$Year[i] <- year.i
  data$Week[i] <- week.i
  data$Group[i] <- parsed.i$Semana
  data$Suspected[i] <- parsed.i$Suspected
  data$Confirmed[i] <- parsed.i$Confirmed
  data$CoInf_DENV_CHIKV[i] <- parsed.i$CoInfDenChi
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

#4. Save
if(write_new == TRUE){
  filename <- paste0("Data/chikungunya_", time_stamp,"-years-", paste0(years_var, collapse = "-"), ".csv")
  write.csv(x = data_out, file = filename, row.names = FALSE, quote = FALSE)
}