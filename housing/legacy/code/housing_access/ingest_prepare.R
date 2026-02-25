# Get census housing variables
# Median home value (B25077)
# Median gross rent (B25064)
# Getting all data for VA, MD, and DC for 2009-2019 counties, tracts, and block groups (ACS5)
## Note: Block group data not available for 2012-2019
# Subsetting to NCR

library(tidycensus)
library(tidyverse)
states <- c("VA", "MD", "DC")
geographies <- c("county", "tract", "block group")
b_geographies <- c("county", "tract")
years <- c(2009:2019)
b_years <- c(2013:2019)
price <- NULL
prices <- NULL
for(state in states){
  for(year in years){
    if(year %in% b_years){
      for(geography in geographies){
        price <- get_acs(geography = geography, table = "B25077", state = state, year = year, geometry = FALSE,
                         survey = "acs5",cache_table = TRUE) %>% select(-variable, -moe) %>%
          mutate(measure = "home_value", year = year, region_type = as.character(geography),
                 measure_type = "integer") %>%
          rename(geoid = GEOID, region_name = NAME, value = estimate)
        prices <- rbind(prices, price)
      }
    }
    else{
      for(geography in b_geographies){
        price <- get_acs(geography = geography, table = "B25077", state = state, year = year, geometry = FALSE,
                         survey = "acs5",cache_table = TRUE) %>% select(-variable, -moe) %>%
          mutate(measure = "home_value", year = year, region_type = as.character(geography),
                 measure_type = "integer") %>%
          rename(geoid = GEOID, region_name = NAME, value = estimate)
        prices <- rbind(prices, price)
      }
    }
  }
}
rent <- NULL
rents <- NULL
for(state in states){
  for(year in years){
    if(year %in% b_years){
      for(geography in geographies){
        rent <- get_acs(geography = geography, table = "B25064", state = state, year = year, geometry = FALSE,
                        survey = "acs5",cache_table = TRUE) %>% select(-variable, -moe) %>%
          mutate(measure = "gross_rent", year = year, region_type = as.character(geography),
                 measure_type = "integer") %>%
          rename(geoid = GEOID, region_name = NAME, value = estimate)
        rents <- rbind(rents, rent)
      }
    }
    else{
      for(geography in b_geographies){
        rent <- get_acs(geography = geography, table = "B25064", state = state, year = year, geometry = FALSE,
                        survey = "acs5",cache_table = TRUE) %>% select(-variable, -moe) %>%
          mutate(measure = "gross_rent", year = year, region_type = as.character(geography),
                 measure_type = "integer") %>%
          rename(geoid = GEOID, region_name = NAME, value = estimate)
        rents <- rbind(rents, rent)
      }
    }
  }
}

ncr_counties <- c("^24021|^24031|^24033|^24017|^11001|^51107|^51059|^51153|^51013|^51510|^51683|^51600|^51610|^51685")

# filter to NCR

ncr_prices <- prices %>% dplyr::filter(str_detect(geoid, ncr_counties))
ncr_rents <- rents %>% dplyr::filter(str_detect(geoid, ncr_counties))

access <- rbind(prices, rents)
ncr_access <- rbind(prices, rents)

con <- get_db_conn()
dc_dbWriteTable(con, "dc_transportation_housing", "vadcmd_cttrbg_acs5_2009_2019_housing_access", access)
dc_dbWriteTable(con, "dc_transportation_housing", "ncr_cttrbg_acs5_2009_2019_housing_access", ncr_access)
DBI::dbDisconnect(con)
