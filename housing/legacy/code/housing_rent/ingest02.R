# packages
library(tidycensus)
library(dplyr)
library(ggplot2)
library(viridis)
library(survey)
library(srvyr)

# installed Census API key
readRenviron("~/.Renviron")
Sys.getenv("CENSUS_API_KEY")

all_vars_acs5 <- 
  load_variables(year = 2020, dataset = "acs5")

all_vars_acs5_ratio <- all_vars_acs5 %>%
  filter(concept == "MEDIAN GROSS RENT BY BEDROOMS")


# ACS variables
acs_vars <- c("B25031_001", "B25031_002", "B25031_003", "B25031_004", "B25031_005", 
              "B25031_006", "B25031_007")

# get data for Virginia counties in 2015
acs_data <- get_acs(geography = "zcta",   # <-------- what geography? 
                    state = 36,           # <-------- in which state?
                    zcta = 10005,          
                    variables = acs_vars, # <-------- what variables?
                    year = 2019,          # <-------- in what year?
                    survey = "acs5",      # <-------- which survey?
                    cache_table = TRUE,   # <-------- cache the selected data for future faster access?
                    output = "wide",      # <-------- variables as columns or rows? 
                    geometry = FALSE,      # <-------- include geography geometry? 
                    keep_geo_vars = FALSE)

###PUMS###
pums_vars_2020 <- pums_variables %>% 
  filter(year == 2020, survey == "acs5")

pums_vars_2020 %>% 
  distinct(var_code, var_label, data_type, level)

pums_vars_2020 %>% 
  distinct(var_code, var_label, data_type, level) %>% 
  filter(level == "housing")

narl_pums <- get_pums(
  variables = c("GRNTP", "BDSP"),
  state = "VA",
  puma = "01301",
  survey = "acs5",
  year = 2020
)

sarl_pums <- get_pums(
  variables = c("GRNTP", "BDSP"),
  state = "VA",
  puma = "01302",
  survey = "acs5",
  year = 2020
)

ffx_pums <- get_pums(
  variables = c("GRNTP", "BDSP"),
  state = "VA",
  puma = c("59301", "59302", "59303", "59304", "59305", "59306", "59307", "59308", "59309"),
  survey = "acs5",
  year = 2020
)

narl_1 <- narl_pums %>%
  filter(BDSP == 1, GRNTP != 0)

narl_2 <- narl_pums %>%
  filter(BDSP == 2, GRNTP != 0)

narl_3 <- narl_pums %>%
  filter(BDSP == 3, GRNTP != 0)

narl_4 <- narl_pums %>%
  filter(BDSP == 4, GRNTP != 0)

narl_5 <- narl_pums %>%
  filter(BDSP == 5, GRNTP != 0)

narl_6 <- narl_pums %>%
  filter(BDSP == 6, GRNTP != 0)

narl_1_40th <- quantile(narl_1$GRNTP, 0.4)
narl_2_40th <- quantile(narl_2$GRNTP, 0.4)
narl_3_40th <- quantile(narl_3$GRNTP, 0.4)
narl_4_40th <- quantile(narl_4$GRNTP, 0.4)
narl_5_40th <- quantile(narl_5$GRNTP, 0.4)
narl_6_40th <- quantile(narl_6$GRNTP, 0.4)
hist(narl_2$GRNTP)
###RELEVANT_TABLES: B25063, B25031
###SMALL AREA FMR


