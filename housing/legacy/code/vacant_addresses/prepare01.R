# HUD USPS Vacant Addresses in VA 2015-2021 

# packages
library(readr)
library(RPostgreSQL)
library(dplyr)
library(reshape2)

# set the working directory 
setwd("~/git/sdc.housing")

# load data
vac15 <- read_csv("data/vacant_addresses/original/usps_vac_2015.csv")
vac16 <- read_csv("data/vacant_addresses/original/usps_vac_2016.csv")
vac17 <- read_csv("data/vacant_addresses/original/usps_vac_2017.csv")
vac18 <- read_csv("data/vacant_addresses/original/usps_vac_2018.csv")
vac19 <- read_csv("data/vacant_addresses/original/usps_vac_2019.csv")
vac20 <- read_csv("data/vacant_addresses/original/usps_vac_2020.csv")
vac21 <- read_csv("data/vacant_addresses/original/usps_vac_2021.csv")

vac15['year'] <- 2015
vac16['year'] <- 2016
vac17['year'] <- 2017
vac18['year'] <- 2018
vac19['year'] <- 2019
vac20['year'] <- 2020
vac21['year'] <- 2021

# format for database
con <- dbConnect(PostgreSQL(), 
                 dbname = "sdad",
                 host = "postgis1", 
                 port = 5432,
                 password = Sys.getenv("db_pwd"))

geo_names <- dbGetQuery(con, "SELECT * FROM dc_geographies.ncr_cttrbg_tiger_2010_2020_geo_names")
dbDisconnect(con)

tracts_names <- geo_names %>% filter(region_type=="tract")
county_names <- geo_names %>% filter(region_type=="county")

dfList <- list(vac15=vac15, vac16=vac16, vac17=vac17, vac18=vac18, vac19=vac19, 
               vac20=vac20, vac21=vac21)

############################
# VA CENSUS TRACTS
############################

dfList <- lapply(dfList, function(df) {
  # census tracts in VA only
  df <-  df %>% filter(substr(geoid, 1,2) == "51")
  # select variables
  df <- df %>% select(c("geoid", "year", "ams_res", "ams_bus", "ams_oth", "res_vac",
                        "bus_vac", "oth_vac", "vac_12_24r", "vac_12_24b",
                        "vac_12_24o", "vac_24_36r", "vac_24_36b", "vac_24_36o", 
                        "vac_36_res", "vac_36_bus", "vac_36_oth"))
  df <- df %>% transmute(geoid = geoid, 
                         year = year,
                         tot_adr = ams_res + ams_bus + ams_oth,
                         vac_res_adr = res_vac, 
                         vac_bus_adr = bus_vac, 
                         vac_oth_adr = oth_vac,
                         vac_adr = res_vac + bus_vac + oth_vac, 
                         vac_res_per = res_vac/ams_res * 100,
                         vac_bus_per = bus_vac/ams_bus * 100, 
                         vac_oth_per = oth_vac/ams_oth * 100,
                         vac_per = vac_adr/tot_adr * 100, 
                         vac_res_12plus = vac_12_24r + vac_24_36r + vac_36_res,
                         vac_bus_12plus = vac_12_24b + vac_24_36b + vac_36_bus,
                         vac_oth_12plus = vac_12_24o + vac_24_36o + vac_36_oth,
                         vac_12plus = vac_res_12plus + vac_bus_12plus + vac_bus_12plus)
  
  df <- left_join(df, tracts_names, by=c("geoid"))
  
  # long format
  df <- melt(df,
             id.vars=c("geoid", "region_type", "region_name", "year"),
             variable.name="measure",
             value.name="value")
  
})

df_long <- rbind(dfList[[1]], dfList[[2]])
df_long <- rbind(df_long, dfList[[3]])
df_long <- rbind(df_long, dfList[[4]])
df_long <- rbind(df_long, dfList[[5]])
df_long <- rbind(df_long, dfList[[6]])
df_long <- rbind(df_long, dfList[[7]])

df_long['measure_type'] = "count"
indx1 <- grepl('per', df_long$measure) 
df_long$measure_type[indx1] <- 'percent'

# save the working dataset
# write_csv(df_long, "data/vacant_addresses/working/va_tr_hud_usps_2015_2021_vacant_addresses.csv")

# connect to database
con <- dbConnect(PostgreSQL(), 
                 dbname = "sdad",
                 host = "postgis1", 
                 port = 5432, 
                 password = Sys.getenv("db_pwd"))

dbWriteTable(con, c("dc_transportation_housing", "va_tr_hud_usps_2015_2021_vacant_addresses"), 
             df_long,  row.names = F)


#dbRemoveTable(con, c("dc_transportation_housing", "va_tr_hud_usps_2015_2021_vacant_addresses"))

dbSendStatement(con, "ALTER TABLE dc_transportation_housing.va_tr_hud_usps_2015_2021_vacant_addresses
                    OWNER TO data_commons")

dbDisconnect(con)

#########################
# VA COUNTIES
#########################

dfList <- list(vac15=vac15, vac16=vac16, vac17=vac17, vac18=vac18, vac19=vac19, 
               vac20=vac20, vac21=vac21)

dfList <- lapply(dfList, function(df) {
  # census tracts in VA only
  df <-  df %>% filter(substr(geoid, 1,2) == "51")
  # select variables
  df <- df %>% select(c("geoid", "year", "ams_res", "ams_bus", "ams_oth", "res_vac",
                        "bus_vac", "oth_vac", "vac_12_24r", "vac_12_24b",
                        "vac_12_24o", "vac_24_36r", "vac_24_36b", "vac_24_36o", 
                        "vac_36_res", "vac_36_bus", "vac_36_oth"))
  
  df <- df %>% transmute(geoid = substr(geoid, 1,5), 
                         year = year,
                         tot_adr = ams_res + ams_bus + ams_oth,
                         tot_res = ams_res,
                         tot_bus = ams_bus,
                         tot_oth = ams_oth,
                         vac_res_adr = res_vac, 
                         vac_bus_adr = bus_vac, 
                         vac_oth_adr = oth_vac,
                         vac_adr = res_vac + bus_vac + oth_vac, 
                         vac_res_12plus = vac_12_24r + vac_24_36r + vac_36_res,
                         vac_bus_12plus = vac_12_24b + vac_24_36b + vac_36_bus,
                         vac_oth_12plus = vac_12_24o + vac_24_36o + vac_36_oth,
                         vac_12plus = vac_res_12plus + vac_bus_12plus + vac_bus_12plus)
  
  df <- df %>%  group_by(geoid, year) %>%
    summarise_all(sum,na.rm = TRUE) %>% 
    as.data.frame()
  
  df <- df %>% transmute(geoid = geoid,
                         year = year,
                         tot_adr = tot_adr,
                         vac_res_adr = vac_res_adr,
                         vac_bus_adr = vac_bus_adr,
                         vac_oth_adr = vac_oth_adr,
                         vac_adr = vac_adr,
                         vac_res_per = vac_res_adr/tot_res * 100,
                         vac_bus_per = vac_bus_adr/tot_bus * 100,
                         vac_oth_per = vac_oth_adr/tot_oth * 100,
                         vac_per = vac_adr/tot_adr * 100,
                         vac_res_12plus = vac_res_12plus,
                         vac_bus_12plus = vac_bus_12plus,
                         vac_oth_12plus = vac_oth_12plus,
                         vac_12plus = vac_12plus)

  df <- left_join(df, county_names, by=c("geoid"))
   
  # long format
  df <- melt(df,
             id.vars=c("geoid", "region_type", "region_name", "year"),
             variable.name="measure",
             value.name="value")
  
})

df_long <- rbind(dfList[[1]], dfList[[2]])
df_long <- rbind(df_long, dfList[[3]])
df_long <- rbind(df_long, dfList[[4]])
df_long <- rbind(df_long, dfList[[5]])
df_long <- rbind(df_long, dfList[[6]])
df_long <- rbind(df_long, dfList[[7]])

df_long['measure_type'] = "count"
indx1 <- grepl('per', df_long$measure) 
df_long$measure_type[indx1] <- 'percent'

# save the wroking dataset
#write_csv(df_long, "data/vacant_addresses/working/va_ct_hud_usps_2015_2021_vacant_addresses.csv")

# connect to database
con <- dbConnect(PostgreSQL(), 
                 dbname = "sdad",
                 host = "postgis1", 
                 port = 5432, 
                 password = Sys.getenv("db_pwd"))

dbWriteTable(con, c("dc_transportation_housing", "va_ct_hud_usps_2015_2021_vacant_addresses"), 
             df_long,  row.names = F)


#dbRemoveTable(con, c("dc_transportation_housing", "va_ct_hud_usps_2015_2021_vacant_addresses"))

dbSendStatement(con, "ALTER TABLE dc_transportation_housing.va_ct_hud_usps_2015_2021_vacant_addresses
                    OWNER TO data_commons")

dbDisconnect(con)
