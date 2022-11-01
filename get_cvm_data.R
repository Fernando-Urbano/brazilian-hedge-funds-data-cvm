"Get Data from CVM Funds."
require(tidyverse)
require(lubridate)
require(xml2)
require(rvest)
require(httr)
setwd(here::here())

url_raw <- "http://dados.cvm.gov.br/dados/FI/DOC/INF_DIARIO/DADOS/"

cvm_files = function(url_raw, folder_location, first_date = NULL){
  
  setwd(folder_location)
  
  links <- try(
    httr::GET(url_raw) %>% 
      httr::content("text") %>% 
      xml2::read_html() %>% 
      rvest::html_nodes("a") %>% 
      rvest::html_attr("href")
  )
  
  zip_csv_links <- c(
    links[which(grepl(x = links, pattern = c("*.csv")))],
    links[which(grepl(x = links, pattern = c("*.zip")))]
  )
  
  if (!is.null(first_date)){
    
    first_date = as.Date(first_date)
    selected_folders = seq(first_date, today(), "1 month") %>%
      format("%Y%m")
    zip_csv_links <- zip_csv_links[
      grepl(paste0(selected_folders, collapse = "|"), zip_csv_links)
    ]
    
  }  
  
  current_number = 0
  
  for (new_link in zip_csv_links){
    
    current_number = current_number + 1
    download_link <- paste0(url_raw, new_link)
    
    download.file(
      download_link,
      destfile = new_link
    )
    
    setTxtProgressBar(
      txtProgressBar(min = 0, max = length(zip_csv_links), style = 3),
      current_number
    )
    
  }
  
  setwd(folder_location)
  zip_filenames <- list.files(pattern = "*.zip", full.names = FALSE)
  
  for (new_zip_filename in zip_filenames){
    
    unzip(new_zip_filename, exdir = paste0(folder_location)) 
    print(paste0("Following file unziped: ", new_zip_filename))
    
    if (file.exists(new_zip_filename)) {
      
      try(file.remove(new_zip_filename))
      
    }
    
  }
  
}

# Informes Diarios - Daily Reports
cvm_files(
  url_raw = "http://dados.cvm.gov.br/dados/FI/DOC/INF_DIARIO/DADOS/",
  folder_location = getwd(),
  first_date = "2020-02-01" # First date to input
)

# Informes Diarios Antigos - Old Daily Reports
cvm_files(
  url_raw = "http://dados.cvm.gov.br/dados/FI/DOC/INF_DIARIO/DADOS/HIST/",
  folder_location = getwd()
)

# Perfil Mensal - Monthly Profile
cvm_files(
  url_raw = "http://dados.cvm.gov.br/dados/FI/DOC/PERFIL_MENSAL/DADOS/",
  folder_location = getwd()
)

# Cadastro Fundos - Funds Registration
cvm_files(
  url_raw = "http://dados.cvm.gov.br/dados/FI/CAD/DADOS/",
  folder_location = getwd()
)
