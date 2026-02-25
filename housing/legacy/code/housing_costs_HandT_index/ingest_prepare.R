# This a replication of the H part of the H&T Index for National Capital Region

# packages 
library(dplyr)
library(tidycensus)
library(tidyverse)
library(tigris)
library(RPostgreSQL)
library(data.table)

# set working directory
setwd("~/git/sdc.housing")

#######################
# COUNTIES in DMV AREA
#######################

# county shapes and geoids
dmv_counties <- list(
  dc = "District of Columbia",
  md = c("Charles", "Frederick", "Montgomery", "Prince George's"),
  va = c(
    "Alexandria", "Arlington", "Fairfax", "Falls Church", "Loudoun", "Manassas",
    "Manassas Park", "Prince William"
  )
)
shapes <- list()
for(state in c("dc", "md", "va")){
  # shapes
  counties <- counties(state)
  ## store subsets to combine later
  counties <- counties[counties$NAME %in% dmv_counties[[state]],]
  shapes[[state]] <- list(
    counties = counties)
}
for(level in names(shapes$dc)){
  counties <- do.call(rbind, lapply(shapes, "[[", level))}

counties_GEOID <- counties$GEOID

###################################
# FETCH ACS VARS
###################################

years <- lst(2014,2015,2016,2017,2018, 2019) 
dmv.bg <- map(
  years,
  ~ get_acs(geography = "block group",
            year = .x,
            variables = c(smoc = "B25088_002",
                          med_rent = "B25064_001",
                          owners = "B25003_002",
                          renters = "B25003_003"
            ),
            state = c("VA", "DC", "MD"),
            survey = "acs5",
            output = "wide",
            geometry = TRUE)
) %>% map2(years, ~ mutate(.x, year = .y))

# acs_vars <- get_acs(geography = "block group",
#         year = 2015,
#         variables = c(smoc = "B25088_002",
#                       med_rent = "B25064_001",
#                       owners = "B25003_002",
#                       renters = "B25003_003"
#         ),
#         state = c("VA"),
#         survey = "acs5",
#         output = "wide",
#         geometry = TRUE)

dmv.bg.red <- reduce(dmv.bg, rbind) %>% filter(substr(GEOID, 1, 5) %in% counties_GEOID) %>% 
  transmute(
    GEOID=GEOID,
    NAME = NAME,
    median_mortgage_cost = smocE, 
    median_rent = med_rentE,
    owners = ownersE,
    renters = rentersE,
    smoc_t_owners = smocE * ownersE,
    rent_t_renters = med_rentE * rentersE,
    owners_p_renters = ownersE + rentersE,
    year = year,
    geometry = geometry
  )

# HOUSING COSTS
dmv.bg.red['h_cost'] <- (dmv.bg.red$smoc_t_owners + dmv.bg.red$rent_t_renters) / dmv.bg.red$owners_p_renters
dmv.bg.up <- dmv.bg.red %>% select(GEOID, median_mortgage_cost, median_rent, owners, renters, h_cost, year)

########################
# BLOCK GROUP NAMES
########################

con <- dbConnect(PostgreSQL(), 
                 dbname = "sdad",
                 host = "postgis1", 
                 port = 5432, 
                 password = Sys.getenv("db_pwd"))

geo_names <- dbGetQuery(con, "SELECT * FROM dc_geographies.ncr_cttrbg_tiger_2010_2020_geo_names")

dbDisconnect(con)

bg_names <- geo_names %>% filter(region_type == "block group")

#######################
# FORMAT
#######################

# add geographies names
out_df <- left_join(dmv.bg.up, bg_names, by = c("GEOID"="geoid"))

# long format
out_df_long <- melt(out_df,
                     id.vars=c("GEOID", "region_type", "region_name", "year", "geometry"),
                     variable.name="measure",
                     value.name="value"
)

out_df_long <- out_df_long %>% select(-geometry)

out_df_long['measure_type'] = "dollars"
indx1 <- grepl('owner', out_df_long$measure) 
indx2 <- grepl('renter', out_df_long$measure) 

out_df_long$measure_type[indx1] <- 'count'
out_df_long$measure_type[indx2] <- 'count'

# save to working
#write_csv(out_df_long, "data/housing_cost_HandT_index/working/vadcmd_bg_acs_2014_2019_housing_costs.csv")


#######################
# ADD to DB
#######################
con <- dbConnect(PostgreSQL(), 
                 dbname = "sdad",
                 host = "postgis1", 
                 port = 5432, 
                 password = Sys.getenv("db_pwd"))

dbWriteTable(con, c("dc_transportation_housing", "vadcmd_bg_acs_2014_2019_housing_costs"), 
             out_df_long,  row.names = F)


#dbRemoveTable(con, c("dc_transportation_housing", "vadcmd_bg_acs_2014_2019_housing_costs"))

dbSendStatement(con, "ALTER TABLE dc_transportation_housing.vadcmd_bg_acs_2014_2019_housing_costs
                OWNER TO data_commons")

dbDisconnect(con)

########################
# CHECK
########################
# va.bg <- acs_vars %>%  transmute(
#     GEOID=GEOID,
#     NAME = NAME,
#     smoc = smocE, 
#     med_rent = med_rentE,
#     owners = ownersE,
#     renters = rentersE,
#     smoc_t_owners = smocE * ownersE,
#     rent_t_renters = med_rentE * rentersE,
#     owners_p_renters = ownersE + rentersE,
#     geometry = geometry
#   )
# 
# va.bg['h_cost'] <- (va.bg$smoc_t_owners + va.bg$rent_t_renters) / va.bg$owners_p_renters
# 
# removeQuotes <- function(x) gsub("\"", "", x)
# 
# h_costs_from_index <- read_csv("data/housing_cost_HandT_index/original/htaindex_data_blkgrps_51.csv") %>% 
#   select(blkgrp, h_cost, median_smoc, median_gross_rent, pct_owner_occupied_hu, pct_renter_occupied_hu) %>%
#   mutate_if(is.character, removeQuotes)
# 
# merged <- left_join(va.bg, h_costs_from_index, by=c("GEOID"="blkgrp"))
# merged["diff"] <- merged$h_cost.x - merged$h_cost.y

