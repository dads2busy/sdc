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


#####Comparing Prices from HUD and Apartments.com#####

library(readxl)
library(dplyr)
library(ggplot2)
scraped_prices <- read_excel("~/sdc.housing/data/housing_rent/original/apartments_zip.xlsx")

apartments_ZIP_40th <- data.frame(matrix(NA, nrow = 0, ncol = 9))

for (i in unique(apartments_zip$ZIP)){
  datalist <- data.frame(matrix(NA, nrow = 0, ncol = 3))
  colnames(datalist) <- c("mean_rent", "bedrooms", "ZIP")
  for (j in 1:length(apartments_zip$ZIP)){ 
    if (apartments_zip$ZIP[j] == i){
      datalist <- rbind(datalist, apartments_zip[j,])}}
    if (nrow(datalist) != 0){
    scraped_prices_0 <- datalist %>%
      filter(bedrooms == 0)
    
    scraped_prices_1 <- datalist %>%
      filter(bedrooms == 1)
    
    scraped_prices_2 <- datalist %>%
      filter(bedrooms == 2)
    
    scraped_prices_3 <- datalist %>%
      filter(bedrooms == 3)
    
    scraped_prices_4 <- datalist %>%
      filter(bedrooms == 4)
    
    scraped_prices_5 <- datalist %>%
      filter(bedrooms == 5)
    
    scraped_prices_6 <- datalist %>%
      filter(bedrooms == 6)
    
    scraped_prices_7 <- datalist %>%
      filter(bedrooms == 7)
    
    bed_0_40th <- quantile(scraped_prices_0$mean_rent, 0.4)
    bed_1_40th <- quantile(scraped_prices_1$mean_rent, 0.4)
    bed_2_40th <- quantile(scraped_prices_2$mean_rent, 0.4)
    bed_3_40th <- quantile(scraped_prices_3$mean_rent, 0.4)
    bed_4_40th <- quantile(scraped_prices_4$mean_rent, 0.4)
    bed_5_40th <- quantile(scraped_prices_5$mean_rent, 0.4)
    bed_6_40th <- quantile(scraped_prices_6$mean_rent, 0.4)
    bed_7_40th <- quantile(scraped_prices_7$mean_rent, 0.4)
    apartments_ZIP_40th <- rbind(apartments_ZIP_40th, c(i, bed_0_40th,bed_1_40th,
                                                                bed_2_40th,bed_3_40th,
                                                                bed_4_40th,bed_5_40th,
                                                                bed_6_40th,bed_7_40th))}}
colnames(apartments_ZIP_40th) <- c("ZIP","0 Bed","1 Bed","2 Bed","3 Bed", 
                                   "4 Bed","5 Bed","6 Bed","7 Bed")

colnames(safmr_ffx) <- c("ZIP", "0 Bed", "1 Bed", "2 Bed", "3 Bed", "4 Bed")
intersection <- base::intersect(safmr_ffx$ZIP, apartments_ZIP_40th$ZIP)

comparison <- merge(safmr_ffx,apartments_ZIP_40th,by="ZIP")
comparison <- comparison[, -c(12, 13, 14)]
correlation_data <- data.frame(matrix(NA, nrow = 0, ncol = 3))
for (i in 2:6){
  HUD_40 <- (comparison[,i])
  apartments_40 <- (comparison[,i + 5])
  compare_dataframe <- cbind(HUD_40, apartments_40, comparison$ZIP)
  correlation_data <- rbind(correlation_data, compare_dataframe)
}
correlation_data <- na.omit(correlation_data)
View(correlation_data)
colnames(correlation_data) <- c("HUD_40", "apartments_40", "ZIP")
cor(correlation_data$compare_list1, correlation_data$compare_list2)


apartments_22102 <- apartments_zip %>%
  filter(ZIP == 22102)
  
apartments_22102$bedrooms <- as.character(apartments_22102$bedrooms)  
safmr_22102 <- as.list(safmr_ffx[35,])
plot_list <- list()
for (i in 2:3){
 plot_data <- apartments_22102 %>%
   filter(bedrooms == as.character(i - 1))
 plot_list[[i]] <- ggplot(plot_data, aes(x=mean_rent)) +
                      geom_histogram(fill="blue", binwidth = 200) +
                      geom_vline(aes_string(xintercept=1.1*safmr_22102[[i+1]], color = "'HUD'"), 
                                 linetype="dashed", size=1) +
                      geom_vline(aes_string(xintercept=apartments_ZIP_40th[27, i+1], color = "'Apartments.com'"), 
                                 linetype="dashed", size=1) +
                      scale_color_manual(name = "40th Percentile Marks", values = c(HUD = "red", Apartments.com = "green")) +
                      labs(title = paste0("Monthly Rent for ", as.character(i - 1), " Bedrooms in ZIP Code 22102 on Apartments.com"), x = "Monthly Rent")}
print(plot_list)

apartments_20171 <- apartments_zip %>%
  filter(ZIP == 20171)

apartments_20171$bedrooms <- as.character(apartments_20171$bedrooms)  
safmr_20171 <- as.list(safmr_ffx[8,])
plot_list <- list()
for (i in 2:3){
  plot_data <- apartments_20171 %>%
    filter(bedrooms == as.character(i - 1))
  plot_list[[i]] <- ggplot(plot_data, aes(x=mean_rent)) +
    geom_histogram(fill="blue", binwidth = 200) +
    geom_vline(aes_string(xintercept=1.1*safmr_20171[[i+1]], color = "'HUD'"), 
               linetype="dashed", size=1) +
    geom_vline(aes_string(xintercept=apartments_ZIP_40th[6, i+1], color = "'Apartments.com'"), 
               linetype="dashed", size=1) +
    scale_color_manual(name = "40th Percentile Marks", values = c(HUD = "red", Apartments.com = "green")) +
    labs(title = paste0("Monthly Rent for ", as.character(i - 1), " Bedrooms in ZIP Code 20171 on Apartments.com"), x = "Monthly Rent")}
print(plot_list)


table(apartments_zip$ZIP)

mean_data <- apartments_zip %>% group_by(ZIP) %>% summarise(mean = mean(mean_rent), num = n()) %>% arrange(-mean)
View(mean_data)

mean_data <- merge(mean_data, correlation_data, by = "ZIP")
