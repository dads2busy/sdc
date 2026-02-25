# Compare Lodes data

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


# load the data ------------------------------------------------------------
lodes <- read_csv('Microdata/Lodes/data/working/va_lodes_bg_tr_co_20102019.csv.xz')
temp_bg2010 <- block_groups("VA", "059", 2010) %>% select(geoid=GEOID, geometry) %>% st_drop_geometry() %>% mutate(geoid=as.numeric(geoid))
geoid_list <- unique(temp_bg2010$geoid)


# estimate employment by industry (fairfax county)
lodes_bgva2017 <- lodes %>% filter(geotype=='block group') %>% filter (state=='VA') %>% filter(year==2017)
lodes_fairfax_cnty <- lodes_bgva2017 %>% 
  filter(geoid %in% geoid_list) %>%
  group_by(naics_name) %>%
  summarise(employment=sum(jobs, na.rm=T))

