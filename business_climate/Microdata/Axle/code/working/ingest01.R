# Extract data from axle (2017)

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


# load data -----------------------------------------
axle <- read_csv("/project/biocomplexity/sdad/projects_data/data_commons/data_axle_data/BUSINESS_HISTORICAL_2017.csv.zip")
axle_fairfax <- axle %>% filter(`FIPS Code`=='51059')

# save the data --------------------------------------------------------------------------------------------------------
savepath = "Microdata/Axle/data/working/"
readr::write_csv(axle_fairfax, xzfile(paste0(savepath,"va059_axle_micro_2017.csv.xz"), compression = 9))



