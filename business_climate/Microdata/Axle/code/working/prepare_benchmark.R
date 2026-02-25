# Build data for bechnmarking

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


# upload the data ----------------------------------------------------------------------------------
uploadpath = "Microdata/Axle/data/working/"
axle <-  read_csv(paste0(uploadpath,"va059_axle_micro_2017.csv.xz"))


