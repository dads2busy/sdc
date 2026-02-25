# List of registred minority company in Fairfax county

# library --------------------------------------------------------------------------
library(dplyr)
library(sf)
library(httr)
library(sp)
library(data.table)
library(stringr)
library(tidyr)
library(readr)
library(tidyverse)
library(tidycensus)
library(tigris)
library(rjson)
library(jsonlite)
library(dplyr)
library(zipcodeR)

# Fairfax counties zip codes --------------------------------------------------------------------------
temp <- search_state('VA') %>% filter(county=='Fairfax County') 
zip_fairfax_cnty <- unique(temp$zipcode)

# load sbsd data ---------------------------------------------------------------------------------------
uploadpath = "Microdata/sbsd_downloaded/data/working/"
sbsd_fairfax_MI <-  read_csv(paste0(uploadpath,"sbsd.csv")) %>%
  select(certif=`Certification Type`,company_name=`Company Name...7`,zipcode=`Zip...14`) %>%
  filter(zipcode %in% zip_fairfax_cnty) %>%
  filter(grepl('Minority Owned', certif) ) %>%
  mutate(company_name01=tolower(company_name))

# list of companies 
company_list <- unique(sbsd_fairfax_MI$company_name01)

# save the data ---------------------------------------------------------------------------------------
savepath = "Microdata/sbsd_downloaded/data/working/"
readr::write_csv(sbsd_fairfax_MI, xzfile(paste0(savepath,"sbsd_minorityregistered_fairfax.csv.xz"), compression = 9))





