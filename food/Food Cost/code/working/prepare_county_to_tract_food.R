library(readxl)
library(sf)
library(dplyr)

va_tracts <- st_read("~/git/cost-living/data/Shapefile_VA_tract", int64_as_string = TRUE, stringsAsFactors = F)
va_tracts <- dplyr::select(as.data.frame(va_tracts), -geometry)[,c(1:2, 5)]
colnames(va_tracts) <- c("State", "County", "Tract")
va_tracts$GEOID <- paste0(va_tracts$State, va_tracts$County)
va_tracts <- va_tracts[,c(3, 4)]

VA_Food <- read_excel("~/git/cost-living/Food cost/data/Working/va_ct_usda_sep22_adjusted_low_cost_meal_plan_costs.xlsx")
VA_Food$GEOID <- as.character(VA_Food$FIPS)
VA_Food <- VA_Food[,-c(1,2)]
VA_Food <- left_join(va_tracts, VA_Food, by="GEOID")

write.xlsx(VA_Food,"~/git/cost-living/Food cost/data/Working/va_tr_usda_sep22_adjusted_low_cost_meal_plan_costs.xlsx")
