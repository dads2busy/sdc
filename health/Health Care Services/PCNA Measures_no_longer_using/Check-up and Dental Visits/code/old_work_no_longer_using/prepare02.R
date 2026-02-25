# packages
library(tidycensus)
library(dplyr)
library(data.table)
library(rstan)
library(cmdstanr)
library(posterior)
library(survey)

# working directory
setwd("~/git/sdc.health_dev/Health Care Services/PCNA Measures/Check-up and Dental Visits")

options(mc.cores = parallel::detectCores())
rstan_options(auto_write = TRUE)

source("mrp_utils.R")

### get data to fit MRP model ###
va_brfss <- readRDS("/project/biocomplexity/sdad/projects_data/mc/data_commons/dc_health_behavior_diet/brfss/va_2012_clean.rds")
# drop refuse and don't know responses
va_brfss <- va_brfss[!(va_brfss$lastden3 %in% c(7, 9, NA)),]
va_brfss$lastden_binary <- ifelse(va_brfss$lastden3 == 1, 1, 0)

# get ACS county data  #
acs_var_2012 <- c("B16009_001", "B16009_002",
                  "B23025_001", "B23025_002",
                  "B06009_001", "B06009_002")


acs_cnty_var <- get_acs(geography = "county", 
                        state = 51,
                        variables = acs_var_2012,
                        year = 2012, 
                        survey = "acs5",
                        cache_table = TRUE, 
                        output = "wide", 
                        geometry = FALSE,
                        keep_geo_vars = FALSE)

acs_cnty_var <- acs_cnty_var %>%
  transmute(fips = GEOID,
            frac_poverty = B16009_002E / B16009_001E,
            frac_in_labor_force = B23025_002E / B23025_001E,
            frac_less_than_HS = B06009_002E / B06009_001E)


acs_cnty_var$frac_poverty <- (acs_cnty_var$frac_poverty - mean(acs_cnty_var$frac_poverty))/sd(acs_cnty_var$frac_poverty)
acs_cnty_var$frac_in_labor_force <- (acs_cnty_var$frac_in_labor_force - mean(acs_cnty_var$frac_in_labor_force))/sd(acs_cnty_var$frac_in_labor_force)
acs_cnty_var$frac_less_than_HS <- (acs_cnty_var$frac_less_than_HS - mean(acs_cnty_var$frac_less_than_HS))/sd(acs_cnty_var$frac_less_than_HS)

acs_cnty_var <- acs_cnty_var %>%
  filter(fips %in% unique(va_brfss$fips)) %>%
  arrange(fips) %>%
  as.data.frame()


### get prediction data at tract level ###

# get ACS tract data for model #
acs_var_tract <- c("B17020_001", "B17020_002",
                   "B23025_001", "B23025_002",
                   "B06009_001", "B06009_002")

acs_tract_var <- get_acs(geography = "tract", 
                         state = 51,
                         variables = acs_var_tract,
                         year = 2018, 
                         survey = "acs5",
                         cache_table = TRUE, 
                         output = "wide", 
                         geometry = FALSE,
                         keep_geo_vars = FALSE)

acs_tract_var <- acs_tract_var %>%
  transmute(tract_fips = GEOID,
            fips = substr(tract_fips, 1, 5),
            frac_poverty = B17020_002E / B17020_001E,
            frac_in_labor_force = B23025_002E / B23025_001E,
            frac_less_than_HS = B06009_002E / B06009_001E)

acs_tract_var <- acs_tract_var[complete.cases(acs_tract_var),]

acs_tract_var$frac_poverty <- (acs_tract_var$frac_poverty - mean(acs_tract_var$frac_poverty))/sd(acs_tract_var$frac_poverty)
acs_tract_var$frac_in_labor_force <- (acs_tract_var$frac_in_labor_force - mean(acs_tract_var$frac_in_labor_force))/sd(acs_tract_var$frac_in_labor_force)
acs_tract_var$frac_less_than_HS <- (acs_tract_var$frac_less_than_HS - mean(acs_tract_var$frac_less_than_HS))/sd(acs_tract_var$frac_less_than_HS)

acs_tract_var <- acs_tract_var %>%
  arrange(fips, tract_fips) %>%
  as.data.frame()

sort_fips <- sort(unique(acs_tract_var$fips))
acs_tract_var$fips_cat <- match(acs_tract_var$fips, sort_fips)


# get poststratification data #

acs_ps_vars <- c(
  # male, 18-19, white
  "B01001A_007",
  # male, 20-24, white
  "B01001A_008",
  # male, 25-29, white
  "B01001A_009",
  # male, 30-34, white
  "B01001A_010",
  # male, 35-44, white
  "B01001A_011",
  # male, 45-54, white
  "B01001A_012",
  # male, 55-64, white
  "B01001A_013",
  # male, 65-74, white
  "B01001A_014",
  # male, 75-84, white
  "B01001A_015",
  # male, 85+, white
  "B01001A_016",
  # female, 18-19, white
  "B01001A_022",
  # female, 20-24, white
  "B01001A_023",
  # female, 25-29, white
  "B01001A_024",
  # female, 30-34, white
  "B01001A_025",
  # female, 35-44, white
  "B01001A_026",
  # female, 45-54, white
  "B01001A_027",
  # female, 55-64, white
  "B01001A_028",
  # female, 65-74, white
  "B01001A_029",
  # female, 75-84, white
  "B01001A_030",
  # female, 85+, white
  "B01001A_031",
  
  # male, 18-19, black
  "B01001B_007",
  # male, 20-24, black
  "B01001B_008",
  # male, 25-29, black
  "B01001B_009",
  # male, 30-34, black
  "B01001B_010",
  # male, 35-44, black
  "B01001B_011",
  # male, 45-54, black
  "B01001B_012",
  # male, 55-64, black
  "B01001B_013",
  # male, 65-74, black
  "B01001B_014",
  # male, 75-84, black
  "B01001B_015",
  # male, 85+, black
  "B01001B_016",
  # female, 18-19, black
  "B01001B_022",
  # female, 20-24, black
  "B01001B_023",
  # female, 25-29, black
  "B01001B_024",
  # female, 30-34, black
  "B01001B_025",
  # female, 35-44, black
  "B01001B_026",
  # female, 45-54, black
  "B01001B_027",
  # female, 55-64, black
  "B01001B_028",
  # female, 65-74, black
  "B01001B_029",
  # female, 75-84, black
  "B01001B_030",
  # female, 85+, black
  "B01001B_031",
  
  # male, 18-19, aian
  "B01001C_007",
  # male, 20-24, aian
  "B01001C_008",
  # male, 25-29, aian
  "B01001C_009",
  # male, 30-34, aian
  "B01001C_010",
  # male, 35-44, aian
  "B01001C_011",
  # male, 45-54, aian
  "B01001C_012",
  # male, 55-64, aian
  "B01001C_013",
  # male, 65-74, aian
  "B01001C_014",
  # male, 75-84, aian
  "B01001C_015",
  # male, 85+, aian
  "B01001C_016",
  # female, 18-19, aian
  "B01001C_022",
  # female, 20-24, aian
  "B01001C_023",
  # female, 25-29, aian
  "B01001C_024",
  # female, 30-34, aian
  "B01001C_025",
  # female, 35-44, aian
  "B01001C_026",
  # female, 45-54, aian
  "B01001C_027",
  # female, 55-64, aian
  "B01001C_028",
  # female, 65-74, aian
  "B01001C_029",
  # female, 75-84, aian
  "B01001C_030",
  # female, 85+, aian
  "B01001C_031",
  
  # male, 18-19, asian
  "B01001D_007",
  # male, 20-24, asian
  "B01001D_008",
  # male, 25-29, asian
  "B01001D_009",
  # male, 30-34, asian
  "B01001D_010",
  # male, 35-44, asian
  "B01001D_011",
  # male, 45-54, asian
  "B01001D_012",
  # male, 55-64, asian
  "B01001D_013",
  # male, 65-74, asian
  "B01001D_014",
  # male, 75-84, asian
  "B01001D_015",
  # male, 85+, asian
  "B01001D_016",
  # female, 18-19, asian
  "B01001D_022",
  # female, 20-24, asian
  "B01001D_023",
  # female, 25-29, asian
  "B01001D_024",
  # female, 30-34, asian
  "B01001D_025",
  # female, 35-44, asian
  "B01001D_026",
  # female, 45-54, asian
  "B01001D_027",
  # female, 55-64, asian
  "B01001D_028",
  # female, 65-74, asian
  "B01001D_029",
  # female, 75-84, asian
  "B01001D_030",
  # female, 85+, asian
  "B01001D_031",
  
  # male, 18-19, nhpi
  "B01001E_007",
  # male, 20-24, nhpi
  "B01001E_008",
  # male, 25-29, nhpi
  "B01001E_009",
  # male, 30-34, nhpi
  "B01001E_010",
  # male, 35-44, nhpi
  "B01001E_011",
  # male, 45-54, nhpi
  "B01001E_012",
  # male, 55-64, nhpi
  "B01001E_013",
  # male, 65-74, nhpi
  "B01001E_014",
  # male, 75-84, nhpi
  "B01001E_015",
  # male, 85+, nhpi
  "B01001E_016",
  # female, 18-19, nhpi
  "B01001E_022",
  # female, 20-24, nhpi
  "B01001E_023",
  # female, 25-29, nhpi
  "B01001E_024",
  # female, 30-34, nhpi
  "B01001E_025",
  # female, 35-44, nhpi
  "B01001E_026",
  # female, 45-54, nhpi
  "B01001E_027",
  # female, 55-64, nhpi
  "B01001E_028",
  # female, 65-74, nhpi
  "B01001E_029",
  # female, 75-84, nhpi
  "B01001E_030",
  # female, 85+, nhpi
  "B01001E_031",
  
  # male, 18-19, other
  "B01001F_007",
  # male, 20-24, other
  "B01001F_008",
  # male, 25-29, other
  "B01001F_009",
  # male, 30-34, other
  "B01001F_010",
  # male, 35-44, other
  "B01001F_011",
  # male, 45-54, other
  "B01001F_012",
  # male, 55-64, other
  "B01001F_013",
  # male, 65-74, other
  "B01001F_014",
  # male, 75-84, other
  "B01001F_015",
  # male, 85+, other
  "B01001F_016",
  # female, 18-19, other
  "B01001F_022",
  # female, 20-24, other
  "B01001F_023",
  # female, 25-29, other
  "B01001F_024",
  # female, 30-34, other
  "B01001F_025",
  # female, 35-44, other
  "B01001F_026",
  # female, 45-54, other
  "B01001F_027",
  # female, 55-64, other
  "B01001F_028",
  # female, 65-74, other
  "B01001F_029",
  # female, 75-84, other
  "B01001F_030",
  # female, 85+, other
  "B01001F_031",
  
  # male, 18-19, multi
  "B01001G_007",
  # male, 20-24, multi
  "B01001G_008",
  # male, 25-29, multi
  "B01001G_009",
  # male, 30-34, multi
  "B01001G_010",
  # male, 35-44, multi
  "B01001G_011",
  # male, 45-54, multi
  "B01001G_012",
  # male, 55-64, multi
  "B01001G_013",
  # male, 65-74, multi
  "B01001G_014",
  # male, 75-84, multi
  "B01001G_015",
  # male, 85+, multi
  "B01001G_016",
  # female, 18-19, multi
  "B01001G_022",
  # female, 20-24, multi
  "B01001G_023",
  # female, 25-29, multi
  "B01001G_024",
  # female, 30-34, multi
  "B01001G_025",
  # female, 35-44, multi
  "B01001G_026",
  # female, 45-54, multi
  "B01001G_027",
  # female, 55-64, multi
  "B01001G_028",
  # female, 65-74, multi
  "B01001G_029",
  # female, 75-84, multi
  "B01001G_030",
  # female, 85+, multi
  "B01001G_031",
  
  # male, 18-19, hispanic
  "B01001I_007",
  # male, 20-24, hispanic
  "B01001I_008",
  # male, 25-29, hispanic
  "B01001I_009",
  # male, 30-34, hispanic
  "B01001I_010",
  # male, 35-44, hispanic
  "B01001I_011",
  # male, 45-54, hispanic
  "B01001I_012",
  # male, 55-64, hispanic
  "B01001I_013",
  # male, 65-74, hispanic
  "B01001I_014",
  # male, 75-84, hispanic
  "B01001I_015",
  # male, 85+, hispanic
  "B01001I_016",
  # female, 18-19, hispanic
  "B01001I_022",
  # female, 20-24, hispanic
  "B01001I_023",
  # female, 25-29, hispanic
  "B01001I_024",
  # female, 30-34, hispanic
  "B01001I_025",
  # female, 35-44, hispanic
  "B01001I_026",
  # female, 45-54, hispanic
  "B01001I_027",
  # female, 55-64, hispanic
  "B01001I_028",
  # female, 65-74, hispanic
  "B01001I_029",
  # female, 75-84, hispanic
  "B01001I_030",
  # female, 85+, hispanic
  "B01001I_031"
)

va_acs_ps <- get_acs(geography = "tract", 
                     state = 51,
                     variables = acs_ps_vars,
                     year = 2018, 
                     survey = "acs5",
                     cache_table = TRUE, 
                     output = "wide", 
                     geometry = FALSE,
                     keep_geo_vars = FALSE)

va_acs_ps <- va_acs_ps %>%
  transmute(tract_fips = GEOID,
            male_18_24_white = B01001A_007E + B01001A_008E,
            male_25_34_white = B01001A_009E + B01001A_010E,
            male_35_44_white = B01001A_011E,
            male_45_54_white = B01001A_012E,
            male_55_64_white = B01001A_013E,
            male_65_74_white = B01001A_014E,
            male_75_plus_white = B01001A_015E + B01001A_016E,
            female_18_24_white = B01001A_022E + B01001A_023E,
            female_25_34_white = B01001A_024E + B01001A_025E,
            female_35_44_white = B01001A_026E,
            female_45_54_white = B01001A_027E,
            female_55_64_white = B01001A_028E,
            female_65_74_white = B01001A_029E,
            female_75_plus_white = B01001A_030E + B01001A_031E,
            male_18_24_black = B01001B_007E + B01001B_008E,
            male_25_34_black = B01001B_009E + B01001B_010E,
            male_35_44_black = B01001B_011E,
            male_45_54_black = B01001B_012E,
            male_55_64_black = B01001B_013E,
            male_65_74_black = B01001B_014E,
            male_75_plus_black = B01001B_015E + B01001B_016E,
            female_18_24_black = B01001B_022E + B01001B_023E,
            female_25_34_black = B01001B_024E + B01001B_025E,
            female_35_44_black = B01001B_026E,
            female_45_54_black = B01001B_027E,
            female_55_64_black = B01001B_028E,
            female_65_74_black = B01001B_029E,
            female_75_plus_black = B01001B_030E + B01001B_031E,
            male_18_24_aian = B01001C_007E + B01001C_008E,
            male_25_34_aian = B01001C_009E + B01001C_010E,
            male_35_44_aian = B01001C_011E,
            male_45_54_aian = B01001C_012E,
            male_55_64_aian = B01001C_013E,
            male_65_74_aian = B01001C_014E,
            male_75_plus_aian = B01001C_015E + B01001C_016E,
            female_18_24_aian = B01001C_022E + B01001C_023E,
            female_25_34_aian = B01001C_024E + B01001C_025E,
            female_35_44_aian = B01001C_026E,
            female_45_54_aian = B01001C_027E,
            female_55_64_aian = B01001C_028E,
            female_65_74_aian = B01001C_029E,
            female_75_plus_aian = B01001C_030E + B01001C_031E,
            male_18_24_asian = B01001D_007E + B01001D_008E,
            male_25_34_asian = B01001D_009E + B01001D_010E,
            male_35_44_asian = B01001D_011E,
            male_45_54_asian = B01001D_012E,
            male_55_64_asian = B01001D_013E,
            male_65_74_asian = B01001D_014E,
            male_75_plus_asian = B01001D_015E + B01001D_016E,
            female_18_24_asian = B01001D_022E + B01001D_023E,
            female_25_34_asian = B01001D_024E + B01001D_025E,
            female_35_44_asian = B01001D_026E,
            female_45_54_asian = B01001D_027E,
            female_55_64_asian = B01001D_028E,
            female_65_74_asian = B01001D_029E,
            female_75_plus_asian = B01001D_030E + B01001D_031E,
            male_18_24_nhpi = B01001E_007E + B01001E_008E,
            male_25_34_nhpi = B01001E_009E + B01001E_010E,
            male_35_44_nhpi = B01001E_011E,
            male_45_54_nhpi = B01001E_012E,
            male_55_64_nhpi = B01001E_013E,
            male_65_74_nhpi = B01001E_014E,
            male_75_plus_nhpi = B01001E_015E + B01001E_016E,
            female_18_24_nhpi = B01001E_022E + B01001E_023E,
            female_25_34_nhpi = B01001E_024E + B01001E_025E,
            female_35_44_nhpi = B01001E_026E,
            female_45_54_nhpi = B01001E_027E,
            female_55_64_nhpi = B01001E_028E,
            female_65_74_nhpi = B01001E_029E,
            female_75_plus_nhpi = B01001E_030E + B01001E_031E,
            male_18_24_other = B01001F_007E + B01001F_008E,
            male_25_34_other = B01001F_009E + B01001F_010E,
            male_35_44_other = B01001F_011E,
            male_45_54_other = B01001F_012E,
            male_55_64_other = B01001F_013E,
            male_65_74_other = B01001F_014E,
            male_75_plus_other = B01001F_015E + B01001F_016E,
            female_18_24_other = B01001F_022E + B01001F_023E,
            female_25_34_other = B01001F_024E + B01001F_025E,
            female_35_44_other = B01001F_026E,
            female_45_54_other = B01001F_027E,
            female_55_64_other = B01001F_028E,
            female_65_74_other = B01001F_029E,
            female_75_plus_other = B01001F_030E + B01001F_031E,
            male_18_24_multi = B01001G_007E + B01001G_008E,
            male_25_34_multi = B01001G_009E + B01001G_010E,
            male_35_44_multi = B01001G_011E,
            male_45_54_multi = B01001G_012E,
            male_55_64_multi = B01001G_013E,
            male_65_74_multi = B01001G_014E,
            male_75_plus_multi = B01001G_015E + B01001G_016E,
            female_18_24_multi = B01001G_022E + B01001G_023E,
            female_25_34_multi = B01001G_024E + B01001G_025E,
            female_35_44_multi = B01001G_026E,
            female_45_54_multi = B01001G_027E,
            female_55_64_multi = B01001G_028E,
            female_65_74_multi = B01001G_029E,
            female_75_plus_multi = B01001G_030E + B01001G_031E,
            male_18_24_hispanic = B01001I_007E + B01001I_008E,
            male_25_34_hispanic = B01001I_009E + B01001I_010E,
            male_35_44_hispanic = B01001I_011E,
            male_45_54_hispanic = B01001I_012E,
            male_55_64_hispanic = B01001I_013E,
            male_65_74_hispanic = B01001I_014E,
            male_75_plus_hispanic = B01001I_015E + B01001I_016E,
            female_18_24_hispanic = B01001I_022E + B01001I_023E,
            female_25_34_hispanic = B01001I_024E + B01001I_025E,
            female_35_44_hispanic = B01001I_026E,
            female_45_54_hispanic = B01001I_027E,
            female_55_64_hispanic = B01001I_028E,
            female_65_74_hispanic = B01001I_029E,
            female_75_plus_hispanic = B01001I_030E + B01001I_031E
  )


# construct poststratification matrix
ps_mat <- va_acs_ps %>%
  filter(tract_fips %in% unique(acs_tract_var$tract_fips))

tract_name <- ps_mat$tract_fips

ps_mat <- ps_mat %>%
  select(-c(1)) %>%
  as.data.frame()

rownames(ps_mat) <- tract_name

# indicator for which counties are missing from BRFSS data
county_missing_ind <- as.numeric(!(unique(acs_tract_var$fips) %in% acs_cnty_var$fips))


#### get state prev est from brfss ####
brfss_2018 <- readRDS("/project/biocomplexity/sdad/projects_data/mc/data_commons/dc_health_behavior_diet/brfss/2018_main.rds")

# dentist visits
brfss_2018 <- brfss_2018[!(brfss_2018$lastden4 %in% c(7, 9, NA)),]
brfss_2018$lastden_binary <- ifelse(brfss_2018$lastden4 == 1, 1, 0)

# Set options for allowing a single observation per stratum options
options(survey.lonely.psu = "adjust")
va_brfss_2018 <- brfss_2018[brfss_2018$xstate == 51,]

brfss_2018_design <- svydesign(id = ~ xpsu ,
                               strata = ~ xststr ,
                               data = va_brfss_2018 ,
                               weight = ~ xllcpwt ,
                               nest = TRUE)

st_prev_logit <- qlogis(unname(svymean(~lastden_binary, brfss_2018_design)[1]))

### MRP ###
brfss_mrp <- cmdstan_model("brfss_mrp2.stan")

# physical health #
data_list <- list(N = nrow(va_brfss), 
                       y = va_brfss$lastden_binary,
                       J = ncol(ps_mat), 
                       num_obs_cnty = length(unique(va_brfss$fips_cat)),
                       num_cnty = length(unique(acs_tract_var$fips)),
                       num_tract = length(unique(acs_tract_var$tract_fips)),
                       num_age = length(unique(va_brfss$age_cat)),
                       num_race = length(unique(va_brfss$race2)),
                       state_prev = st_prev_logit,
                       gender = va_brfss$sex,
                       cnty = va_brfss$fips_cat,
                       age = va_brfss$age_cat,
                       race = va_brfss$race2,
                       poverty = acs_cnty_var$frac_poverty,
                       labor_force = acs_cnty_var$frac_in_labor_force,
                       less_than_HS = acs_cnty_var$frac_less_than_HS,
                       poverty_tract = acs_tract_var$frac_poverty,
                       labor_force_tract = acs_tract_var$frac_in_labor_force,
                       less_than_HS_tract = acs_tract_var$frac_less_than_HS,
                       N_pop = as.vector(t(ps_mat)),
                       cnty_miss_ind = county_missing_ind,
                       tract_cnty_map = acs_tract_var$fips_cat)

brfss_mrp_fit <- brfss_mrp$sample(data = data_list, 
                                       seed = 50,
                                       refresh = 0, 
                                       parallel_chains = 10, 
                                       iter_warmup = 1000, 
                                       iter_sampling = 1000,
                                       step_size = 0.1,
                                       adapt_delta = 0.95)

mrp_draws <- brfss_mrp_fit$draws("y_tract")

res <- as.data.frame(summarise_draws(mrp_draws,
                                          mean, median, sd, mad))

ci <- matrix(NA, nrow = nrow(ps_mat), ncol = 2)
for (i in 1:nrow(ps_mat)) {
  ci[i,] <- spin(mrp_draws[,,i],
                      lower = 0, 
                      upper = 1, 
                      conf = 0.95)
}

tract_res <- data.frame(tract_code = rownames(ps_mat),
                             mean = res$mean,
                             median = res$median,
                             sd = res$sd,
                             mad = res$mad,
                             lower_pi = ci[,1],
                             upper_pi = ci[,2])

saveRDS(tract_res, "data/working/dent_2018_pred_tr.rds")

total_18_plus_pop <- c("B01001_007", "B01001_008", "B01001_009", "B01001_010",
                       "B01001_011", "B01001_012", "B01001_013", "B01001_014",
                       "B01001_015", "B01001_016", "B01001_017", "B01001_018",
                       "B01001_016", "B01001_017", "B01001_018", "B01001_019",
                       "B01001_020", "B01001_021", "B01001_022", "B01001_023",
                       "B01001_024", "B01001_025", "B01001_031", "B01001_032",
                       "B01001_033", "B01001_034", "B01001_035", "B01001_036",
                       "B01001_037", "B01001_038", "B01001_039", "B01001_040",
                       "B01001_041", "B01001_042", "B01001_043", "B01001_044",
                       "B01001_044", "B01001_045", "B01001_046", "B01001_047",
                       "B01001_048", "B01001_049")

tract_pop_2018 <- get_acs(geography = "tract", 
                          state = 51,
                          variables = total_18_plus_pop,
                          year = 2018, 
                          survey = "acs5",
                          cache_table = TRUE, 
                          output = "wide", 
                          geometry = FALSE,
                          keep_geo_vars = FALSE)

tract_pop_2018 <- tract_pop_2018 %>%
  transmute(tract_code = GEOID,
            total_18_plus_pop = B01001_007E + B01001_008E + B01001_009E + 
              B01001_010E + B01001_011E + B01001_012E + B01001_013E +
              B01001_014E + B01001_015E + B01001_016E + B01001_017E +
              B01001_018E + B01001_019E + B01001_020E + B01001_021E +
              B01001_022E + B01001_023E + B01001_024E + B01001_025E +
              B01001_031E + B01001_032E + B01001_033E + B01001_034E +
              B01001_035E + B01001_036E + B01001_037E + B01001_038E +
              B01001_039E + B01001_040E + B01001_041E + B01001_042E +
              B01001_043E + B01001_044E + B01001_045E + B01001_046E +
              B01001_047E + B01001_048E + B01001_049E) %>%
  as.data.frame()

aggregate_tract_est <- tract_res %>%
  inner_join(tract_pop_2018, by = "tract_code")
aggregate_tract_est["county_geoid"] <- substr(aggregate_tract_est$tract_code, 1,5)

va_ct_est <- aggregate_tract_est %>% group_by(county_geoid) %>%
  summarize(prop_check = sum(mean * total_18_plus_pop,  na.rm = TRUE)/sum(total_18_plus_pop, na.rm = T))

##################
# FORMAT 
##################

# geographies
geos_data <- read_csv("~/git/dc.metadata/data/region_name.csv.xz")
va_counties <- geos_data %>% filter(region_type == "county" & substr(geoid, 1,2) == "51")
va_tracts <- geos_data %>% filter(region_type == "tract" & substr(geoid, 1,2) == "51")

# add geographies names (distance = virginia + space)
out_tr <- left_join(tract_res[c("tract_code","mean")], va_tracts, by = c("tract_code" = "geoid"))
out_ct <- left_join(va_ct_est, va_counties, by = c("county_geoid" = "geoid"))

# add year
out_tr["year"] <- 2019
out_tr["measure"] <- "perc_dental_visit"
out_tr["measure_type"] <- "percent"
out_tr$mean <- out_tr$mean * 100

names(out_tr)[1] <- "geoid"
names(out_tr)[2] <- "value"

# re-arrange columns
out_tr <- out_tr[, c(1, 4, 3, 5, 2, 6, 7)]

# add year
out_ct["year"] <- 2019
out_ct["measure"] <- "perc_dental_visit"
out_ct["measure_type"] <- "percent"
out_ct$prop_check <- out_ct$prop_check * 100

names(out_ct)[1] <- "geoid"
names(out_ct)[2] <- "value"

# re-arrange columns
out_ct <- out_ct[, c(1, 4, 3, 5, 2, 6, 7)]

#write_csv(out_tr, "data/distribution/va_tr_brfss_2018_percent_annual_dental_visit.csv")
#write_csv(out_ct, "data/distribution/va_ct_brfss_2018_percent_annual_dental_visit.csv")

