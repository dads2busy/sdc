# PNCA Indicators: Total number of graduates from Virginia Institutions 
# completing degrees in health professions
# Data is downloaded from SCHEV: https://research.schev.edu//localities/LD11_HLDegreesAwarded.asp
# SHEV Higher Ed Data LD11: Healthcare Professions Degrees Awarded, by Student Origin

# packages
library(tidyverse)
library(dplyr)
library(readr)
library(fuzzyjoin)
library(viridis)

# working directory
setwd("~/git/sdc.health_dev/Health Care Services/Health Professionals/VA Graduates")

all_instuts <- read_csv("data/original/all_institutions_all_students.csv")
public <- read_csv("data/original/public_4_year_all_students.csv")
private <- read_csv("data/original/private_4_year_all_students.csv")
public_2 <- read_csv("data/original/public_2_year_all_students.csv")

# geographies
geos_data <- read_csv("~/git/dc.metadata/data/region_name.csv.xz")
va_counties <- geos_data %>% filter(region_type == "county" & substr(geoid, 1,2) == "51")

colnames(all_instuts) <- c("county_name", "2017", "2018", "2019", "2020", "2021")
colnames(public) <- c("county_name", "2017", "2018", "2019", "2020", "2021")
colnames(private) <- c("county_name", "2017", "2018", "2019", "2020", "2021")
colnames(public_2) <- c("county_name", "2017", "2018", "2019", "2020", "2021")
#######################
# FORMAT
#######################

# add geographies names (distance = virginia + space)
out_all <- stringdist_left_join(all_instuts, va_counties, by = c("county_name" = "region_name"), max_dist = 11)
out_all <- out_all[!is.na(out_all$geoid),]
out_all <- out_all %>% select(-county_name)

out_pub <- stringdist_left_join(public, va_counties, by = c("county_name" = "region_name"), max_dist = 11)
out_pub <- out_pub[!is.na(out_pub$geoid),]
out_pub <- out_pub %>% select(-county_name)

out_priv <- stringdist_left_join(private, va_counties, by = c("county_name" = "region_name"), max_dist = 11)
out_priv <- out_priv[!is.na(out_priv$geoid),]
out_priv <- out_priv %>% select(-county_name)

out_pub2 <- stringdist_left_join(public_2, va_counties, by = c("county_name" = "region_name"), max_dist = 11)
out_pub2 <- out_pub2[!is.na(out_pub2$geoid),]
out_pub2 <- out_pub2 %>% select(-county_name)

# long format
out_all_long <- melt(out_all,
                     id.vars=c("geoid", "region_type", "region_name"),
                     variable.name="year",
                     value.name="value"
)

out_pub_long <- melt(out_pub,
                     id.vars=c("geoid", "region_type", "region_name"),
                     variable.name="year",
                     value.name="value"
)

out_priv_long <- melt(out_priv,
                      id.vars=c("geoid", "region_type", "region_name"),
                      variable.name="year",
                      value.name="value"
)

out_pub2_long <- melt(out_pub2,
                      id.vars=c("geoid", "region_type", "region_name"),
                      variable.name="year",
                      value.name="value"
)

out_all_long["measure"] <- "degrees_awarded"
out_all_long["measure_type"] <- "count"
# re-arrange columns
out_all_long <- out_all_long[, c(1, 2, 3, 4, 6, 5, 7)]

out_pub_long["measure"] <- "degrees_awarded"
out_pub_long["measure_type"] <- "count"
# re-arrange columns
out_pub_long <- out_all_long[, c(1, 2, 3, 4, 6, 5, 7)]

out_priv_long["measure"] <- "degrees_awarded"
out_priv_long["measure_type"] <- "count"
# re-arrange columns
out_priv_long <- out_all_long[, c(1, 2, 3, 4, 6, 5, 7)]

out_pub2_long["measure"] <- "degrees_awarded"
out_pub2_long["measure_type"] <- "count"
# re-arrange columns
out_pub2_long <- out_all_long[, c(1, 2, 3, 4, 6, 5, 7)]

