#SV Scarpino
#July 2018
#PDF to CSV for Puerto Rico MoH Arboviral surveillance data (2016-present)

#set working dir
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))#sets working directory to source file location

#libraries (not included in limits_acc_functions.R)
library(pdftools)

#########
#Globals#
#########
download_new_Informes_Arbovirales <- FALSE #set to TRUE to download files
write_new <- FALSE #set to TRUE to save a new csv
Informes_Arbovirales_path <- "Raw PDFs/Informes Arbovirales/"
time_stamp <- as.numeric(Sys.time())

###########
#acc funcs#
###########
parse_Informes_Arbovirales <- function(filename, path){
  data <- pdf_text(paste0(path, filename))
  data_split <- strsplit(data, "\n")
  
  #Semana
  semana_loc <- grep("Semanas", data_split[[1]])
  semana_raw <- data_split[[1]][semana_loc]
  
  semana_no_em <- gsub(pattern = "\u2014", replacement = "-", semana_raw)
  
  semana_no_space <- gsub(pattern = "- ", replacement = "-", semana_no_em)
  semana_no_space <- gsub(pattern = " -", replacement = "-", semana_no_space)
  semana_no_space <- gsub(pattern = " - ", replacement = "-", semana_no_space)
  
  semana_split <- strsplit(x = semana_no_space, split = " ")
  semana_comma <- paste0(unlist(semana_split)[1:2], collapse = " ")
  semana <- gsub(pattern = ",", replacement = "", semana_comma)
  
  #DENV
  denv <- grep("DENV:",data_split[[1]])
  if(length(denv) == 0){
    denv <- grep("DENV¶:",data_split[[1]])
  }
  if(length(denv) == 0){
      denv <- grep("DENV‣:",data_split[[1]])
  }
  
  #cumulative denv cases  
  denv_cases_cum <- data_split[[1]][denv[2]]
  denv_cases_cum_numbers <- strsplit(denv_cases_cum, "[: ]")[[1]][3]
  denv_cases_cum_numbers <- gsub(pattern = ",", "", denv_cases_cum_numbers)
  denv_cases_cum_numbers <- as.numeric(denv_cases_cum_numbers)
  
  #new denv cases
  denv_cases_new <- data_split[[1]][denv[1]]
  denv_cases_new_numbers <- strsplit(denv_cases_new, "[: ]")[[1]][3]
  denv_cases_new_numbers <- gsub(pattern = ",", "", denv_cases_new_numbers)
  denv_cases_new_numbers <- as.numeric(denv_cases_new_numbers)
  
  #CHIKV
  chik <- grep("CHIKV: ", data_split[[1]])
  
  #cumulative chikv cases
  chik_cases_cum <- data_split[[1]][chik[2]]
  chik_cases_cum_numbers <- strsplit(chik_cases_cum, "[: ]")[[1]][3]
  chik_cases_cum_numbers <- gsub(pattern = ",", "", chik_cases_cum_numbers)
  chik_cases_cum_numbers <- as.numeric(chik_cases_cum_numbers)
  
  #new chikv cases
  chik_cases_new <- data_split[[1]][chik[1]]
  chik_cases_new_numbers <- strsplit(chik_cases_new, "[: ]")[[1]][3]
  chik_cases_new_numbers <- gsub(pattern = ",", "", chik_cases_new_numbers)
  chik_cases_new_numbers <- gsub(pattern = "casos", "", chik_cases_new_numbers)
  chik_cases_new_numbers <- as.numeric(chik_cases_new_numbers)
  
  #ZIKV
  zikv <- grep("ZIKV: ", data_split[[1]])
  
  #cumulative zikv cases
  zikv_cases_cum <- data_split[[1]][zikv[2]]
  zikv_cases_cum_numbers <- strsplit(zikv_cases_cum, "[: ]")[[1]][3]
  zikv_cases_cum_numbers <- gsub(pattern = ",", "", zikv_cases_cum_numbers)
  zikv_cases_cum_numbers <- as.numeric(zikv_cases_cum_numbers)
  
  #new zikv cases
  zikv_cases_new <- data_split[[1]][zikv[1]]
  zikv_cases_new_numbers <- strsplit(zikv_cases_new, "[: ]")[[1]][3]
  zikv_cases_new_numbers <- gsub(pattern = ",", "", zikv_cases_new_numbers)
  zikv_cases_new_numbers <- as.numeric(zikv_cases_new_numbers)
  
  #Flavivirus
  flavi <- grep("Flavivirus: ", data_split[[1]])
  
  #cumulative flavivirus
  flavi_cases_cum <- data_split[[1]][flavi[1]]
  flavi_cases_cum_numbers <- strsplit(flavi_cases_cum, "[: ]")[[1]][3]
  flavi_cases_cum_numbers <- gsub(pattern = ",", "", flavi_cases_cum_numbers)
  flavi_cases_cum_numbers <- as.numeric(flavi_cases_cum_numbers)
  
  #new flavirus
  flavi_cases_new_numbers <- NA #as far as I can tell this is only reported as cumulative
  
  #suspected cases
  data_split[[1]] <- gsub(pattern = "presuntos", replacement = "sospechosos", data_split[[1]])
  data_split[[1]] <- gsub(pattern = "reportes", replacement = "sospechosos", data_split[[1]])
  
  suspected_loc <- grep("sospechosos", data_split[[1]])
  suspected_raw <- data_split[[1]][suspected_loc[2]]
  suspected <- strsplit(x = suspected_raw, split = " ")[[1]][1]
  suspected <- gsub(pattern = ",", "", suspected)
  suspected <- try(as.numeric(suspected), silent = TRUE)
  if(is(suspected)[1] == "try-error"){
    suspected <- NA
  }
  
  return(list("DENV" = denv_cases_cum_numbers, "CHIKV" = chik_cases_cum_numbers, "ZIKV" = zikv_cases_cum_numbers, "Flavivirus" = flavi_cases_cum_numbers, "Semana" = semana, "DENV_new" = denv_cases_new_numbers, "CHIKV_new" = chik_cases_new_numbers, "ZIKV_new" = zikv_cases_new_numbers, "Flavivirus_new" = flavi_cases_new_numbers, "suspected_new" = suspected))
}

###########
#Data Sets#
###########
#1. Download Informes Arbovirales

if(download_new_Informes_Arbovirales == TRUE){
  #Download data
  years <- c(2016,2017,2018)
  base_file <- "http://www.salud.gov.pr/Estadisticas-Registros-y-Publicaciones/Informes%20Arbovirales/Reporte%20ArboV%20semana%20"
  
  missed <- c()
  for(i in years){
    for(j in 1:54){
      loc.file.ij <- paste0(base_file, j, "-", i, ".pdf")
      dest.file.ij <- strsplit(x = loc.file.ij, split = "/")
      dest.file.ij <- dest.file.ij[[1]][6]
      try_ij <- try(download.file(url = loc.file.ij, destfile = paste0(Informes_Arbovirales_path, dest.file.ij)), silent = TRUE)
      if(length(grep("error", try_ij, ignore.case = TRUE)) > 0){
        missed <- c(missed, dest.file.ij)
      }
    }
  }
  #two files with weird naming conventions
  loc.file.ij <- "http://www.salud.gov.pr/Estadisticas-Registros-y-Publicaciones/Informes%20Arbovirales/Reporte%20ArboV%20semana%2052-53%202016.pdf"
  dest.file.ij <- strsplit(x = loc.file.ij, split = "/")
  dest.file.ij <- dest.file.ij[[1]][6]
  try_ij <- try(download.file(url = loc.file.ij, destfile = paste0(Informes_Arbovirales_path, dest.file.ij)), silent = TRUE)
  if(length(grep("error", try_ij, ignore.case = TRUE)) > 0){
    stop("Couldn't find file")
  }
  
  loc.file.ij <- "http://www.salud.gov.pr/Estadisticas-Registros-y-Publicaciones/Informes%20Arbovirales/Reporte%20ArboV%20semana%208%202017.pdf"
  dest.file.ij <- strsplit(x = loc.file.ij, split = "/")
  dest.file.ij <- dest.file.ij[[1]][6]
  try_ij <- try(download.file(url = loc.file.ij, destfile = paste0(Informes_Arbovirales_path, dest.file.ij)), silent = TRUE)
  if(length(grep("error", try_ij, ignore.case = TRUE)) > 0){
    stop("Couldn't find file")
  }
}

#2. Extract data from PDFs
Informes_Arbovirales_files <- list.files("Raw PDFs/Informes Arbovirales/")

data <- matrix(NA, ncol = 12, nrow = length(Informes_Arbovirales_files))
colnames(data) <- c("Year", "Week", "Group", "DENV_cumulative", "CHIKV_cumulative", "ZIKV_cumulative", "Flavivirus_cumulative","DENV_new", "CHIKV_new", "ZIKV_new", "Flavivirus_new", "Suspected_new")
data <- as.data.frame(data)

for(i in 1:length(Informes_Arbovirales_files)){
  file_name.i <- Informes_Arbovirales_files[i]
  year.i <- substr(x = file_name.i, start = nchar(file_name.i)-7, stop = nchar(file_name.i)-4)
  week.i <- strsplit(x = file_name.i, split = "%20")[[1]][4]
  week.i <- strsplit(x = week.i, split = "-")[[1]][1]
  
  parsed.i <- parse_Informes_Arbovirales(filename = file_name.i, path = Informes_Arbovirales_path)
  
  data$Year[i] <- year.i
  data$Week[i] <- week.i
  data$Group[i] <- parsed.i$Semana
  data$DENV_cumulative[i] <- parsed.i$DENV
  data$CHIKV_cumulative[i] <- parsed.i$CHIKV
  data$ZIKV_cumulative[i] <- parsed.i$ZIKV
  data$Flavivirus_cumulative[i] <- parsed.i$Flavivirus
  
  data$DENV_new[i] <- parsed.i$DENV_new
  data$CHIKV_new[i] <- parsed.i$CHIKV_new
  data$ZIKV_new[i] <- parsed.i$ZIKV_new
  data$Flavivirus_new[i] <- parsed.i$Flavivirus_new
  
  data$Suspected_new[i] <- parsed.i$suspected_new
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
  filename <- paste0("Data/Informes_Arbovirales_", time_stamp,"-years-", paste0(years_var, collapse = "-"), ".csv")
  write.csv(x = data_out, file = filename, row.names = FALSE, quote = FALSE)
}