
#########################

library(readxl)
library(sf)
library(sp)
library(tigris)
library(geosphere)
library(dplyr)
library(ggplot2)
library(RPostgreSQL)
fy2022_safmrs_revised <- read_excel("~/sdc.housing/data/housing_rent/original/fy2022_safmrs_revised.xlsx")
View(fy2022_safmrs_revised)

virginia_tracts <- read_sf("~/sdc.housing/data/housing_rent/original/virginia_tracts/virginia_tracts.shp", stringsAsFactors=FALSE)
maryland_tracts <- read_sf("~/sdc.housing/data/housing_rent/original/maryland_tracts/maryland_tracts.shp", stringsAsFactors=FALSE)
DC_tracts <- read_sf("~/sdc.housing/data/housing_rent/original/DC_tracts/DC_tracts.shp", stringsAsFactors=FALSE)

NCR_tracts <- rbind(virginia_tracts, maryland_tracts, DC_tracts)

zip_codes <- read_sf("~/sdc.housing/data/housing_rent/original/ZIP_Code_Shapefiles/tl_2021_us_zcta520.shp", stringsAsFactors=FALSE)
states <- st_as_sf(states())
NCR_states <- states %>%
  filter(is.element(GEOID, c(24, 11, 51)))

mat <- matrix(NA, nrow = 1, ncol = 10)
NCR_zip <- data.frame(mat)
 
inds <- st_intersects(zip_codes$geometry, NCR_states$geometry, sparse=T)
for (i in length(zip_codes$geometry)){
  for (j in length(NCR_states$geometry)){
    if (identical(states$NAME[inds[[j]]],character(0))){
      NCR_zip <- rbind(NCR_zip, zip_codes[i,])
    }
  }
}                    


inds <- st_intersects(zip_codes$geometry, NCR$geometry, sparse=T)
for (i in 1:length(inds)){
  if (identical(states$NAME[inds[[i]]],character(0))){
    zip_codes$stateID[i] <- NA}
  else{
    zip_codes$stateID[i] <- list(states$GEOID[inds[[i]]])
    zip_codes$stateABBR[i] <- list(states$STUSPS[inds[[i]]])
  }}

fy2022_safmrs_revised[,1] <- as.numeric(as.character(unlist(fy2022_safmrs_revised[,1])))
safmr_ffx <- fy2022_safmrs_revised %>%
  filter(fy2022_safmrs_revised[,1] %in% 
           c(22003, 22030, 20171, 22015, 20170, 20120, 22033, 22309, 
             22079, 22306, 22031, 22042, 22312, 22310, 22153, 22032, 
             20191, 20121, 22101, 22150, 22041, 22182, 22043, 20151,
             22180, 22102, 22311, 20190, 22124, 22046, 22151, 22039,
             22066, 20124, 22303, 22181, 22308, 22044, 20194, 22307,
             22060, 22027, 22185, 22035, 20122, 20153, 20172, 20193,
             20192, 20195, 20196, 22009, 22037, 22036, 22047, 22067,
             22081, 22092, 22082, 22095, 22096, 22103, 22107, 22106,
             22109, 22108, 22118, 22116, 22120, 22119, 22122, 22121,
             22158, 22156, 22160, 22159, 22161, 22183, 22184, 22199,
             22315, 22152, 20511))
                    

fy2022_safmrs_revised[,1] <- as.numeric(as.character(unlist(fy2022_safmrs_revised[,1])))
safmr_ffx <- fy2022_safmrs_revised %>%
  filter(fy2022_safmrs_revised[,1] == 22003)                  
                    
                    

safmr_ffx <- fy2022_safmrs_revised %>%
  filter(`ZIP\r\nCode` %in% 
           c(22003, 22030, 20171, 22015, 20170, 20120, 22033, 22309, 
             22079, 22306, 22031, 22042, 22312, 22310, 22153, 22032, 
             20191, 20121, 22101, 22150, 22041, 22182, 22043, 20151,
             22180, 22102, 22311, 20190, 22124, 22046, 22151, 22039,
             22066, 20124, 22303, 22181, 22308, 22044, 20194, 22307,
             22060, 22027, 22185, 22035, 20122, 20153, 20172, 20193,
             20192, 20195, 20196, 22009, 22037, 22036, 22047, 22067,
             22081, 22092, 22082, 22095, 22096, 22103, 22107, 22106,
             22109, 22108, 22118, 22116, 22120, 22119, 22122, 22121,
             22158, 22156, 22160, 22159, 22161, 22183, 22184, 22199,
             22315, 22152, 20511))


print(length(c(22003, 22030, 20171, 22015, 20170, 20120, 22033, 22309, 
              22079, 22306, 22031, 22042, 22312, 22310, 22153, 22032, 
              20191, 20121, 22101, 22150, 22041, 22182, 22043, 20151,
              22180, 22102, 22311, 20190, 22124, 22046, 22151, 22039,
              22066, 20124, 22303, 22181, 22308, 22044, 20194, 22307,
              22060, 22027, 22185, 22035, 20122, 20153, 20172, 20193,
              20192, 20195, 20196, 22009, 22037, 22036, 22047, 22067,
              22081, 22092, 22082, 22095, 22096, 22103, 22107, 22106,
              22109, 22108, 22118, 22116, 22120, 22119, 22122, 22121,
              22158, 22156, 22160, 22159, 22161, 22183, 22184, 22199,
              22315, 22152, 20511)))                    
safmr_ffx <- safmr_ffx[ ,-c(2,3) ]                    
                    
                    
                    





