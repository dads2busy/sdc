# Compare Mergent with ABS data

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
census_api_key(Sys.getenv('census_api_key'))
key <- Sys.getenv('census_api_key')


# load ABS data ------------------------------------------------------------
abs_data <- read_csv('Microdata/ABS_census/data/working/ABSCS2017_employer_firms_by_industry_race.csv')
names <- c('geo_name',
           'naics_code',
           'naics_name',
           'sex',
           'ethnicity',
           'race',
           'veteran',
           'year',
           'number_firms',
           'sales',
           'employment',
           'payroll',
           'moe_number_firms',
           'moe_sales',
           'moe_employment',
           'moe_payroll')
colnames(abs_data) <- names

# subset data
abs_industry <- abs_data %>% 
  filter(race=='Total') %>% 
  select(geo_name,naics_name,year,number_firms,employment,moe_number_firms,moe_employment) %>%
  mutate(naics_code=case_when(
    naics_name=='Agriculture, forestry, fishing and hunting (660)' ~ '11',
    naics_name=='Mining, quarrying, and oil and gas extraction' ~ '21',
    naics_name=='Utilities' ~ '22',
    naics_name=='Construction' ~ '23',
    naics_name=='Manufacturing' ~ '31-33',
    naics_name=='Wholesale trade' ~ '42',
    naics_name=='Retail trade' ~ '44-45',
    naics_name=='Transportation and warehousing (661)' ~ '48-49',
    naics_name=='Information' ~ '51',
    naics_name=='Finance and insurance (662)' ~ '52',
    naics_name=='Real estate and rental and leasing' ~ '53',
    naics_name=='Professional, scientific, and technical services' ~ '54',
    naics_name=='Administrative and support and waste management and remediation services' ~ '56',
    naics_name=='Educational services' ~ '61',
    naics_name=='Health care and social assistance' ~ '62',
    naics_name=='Arts, entertainment, and recreation' ~ '71',
    naics_name=='Accommodation and food services' ~ '72',
    naics_name=='Other services (except public administration) (663)' ~ '81',
    naics_name=='Industries not classified' ~ '99',
    naics_name=='Management of companies and enterprises' ~ '55',
    naics_name=='Total for all sectors' ~ '00'))
abs_race <- abs_data %>% 
  filter(naics_name=='Total for all sectors') %>% 
  select(geo_name,race,year,number_firms,employment,moe_number_firms,moe_employment) %>%
  filter(race %in% c('White','Black or African American','American Indian and Alaska Native','Asian','Native Hawaiian and Other Pacific Islander'))
abs_minority <- abs_data %>% 
  filter(naics_name=='Total for all sectors') %>% 
  select(geo_name,race,year,number_firms,employment,moe_number_firms,moe_employment) %>%
  filter(race %in% c('Minority','Equally minority/nonminority','Nonminority'))



# load mergent intellect ----------------------------------------------------------------------------

# industry
mi_industry_employment <- read_csv('Employment/Industry/data/distribution/va059_bg_mi_20102020_total_employment_by_industry.csv.xz')
mi_industry_business <- read_csv('Business_characteristics/Industry/data/distribution/va059_bg_mi_20102020_number_business_by_industry.csv.xz')

temp_business <- mi_industry_business %>%
  filter(year==2017) %>%
  mutate(industry=str_remove_all(measure, paste('number_business', collapse = "|")),
         industry=gsub("_", "", industry)) %>%
  select(geoid,industry,year,value) %>%
  group_by(industry,year) %>%
  summarise(number_firms=sum(value, na.rm=T))

temp_employment <- mi_industry_employment %>%
  filter(year==2017) %>%
  mutate(industry=str_remove_all(measure, paste('total_employment', collapse = "|")),
         industry=gsub("_", "", industry)) %>%
  select(geoid,industry,year,value) %>%
  group_by(industry,year) %>%
  summarise(employment=sum(value, na.rm=T))

mi_industry <- merge(temp_business,temp_employment, by.x=c('industry','year'), by.y=c('industry','year'))


# minority
mi_minority_employment <- read_csv('Employment/Minority_owned/data/distribution/va059_bg_mi_20102020_total_employment_by_minority.csv.xz')
mi_minority_business <- read_csv('Business_characteristics/Minority_owned/data/distribution/va059_bg_mi_20102020_number_business_by_minority.csv.xz')

temp_business <- mi_minority_business %>%
  filter(year==2017) %>%
  mutate(status=str_remove_all(measure, paste('number_business', collapse = "|")),
         status=gsub("_", "", status)) %>%
  select(geoid,status,year,value) %>%
  group_by(status,year) %>%
  summarise(number_firms=sum(value, na.rm=T))

temp_employment <- mi_minority_employment %>%
  filter(year==2017) %>%
  mutate(status=str_remove_all(measure, paste('total_employment', collapse = "|")),
         status=gsub("_", "", status)) %>%
  select(geoid,status,year,value) %>%
  group_by(status,year) %>%
  summarise(employment=sum(value, na.rm=T))

mi_minority <- merge(temp_business,temp_employment, by.x=c('status','year'), by.y=c('status','year'))


