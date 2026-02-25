# Maps of BRFSS small area estimates for dental and annual check-up visits

library(readr)
library(viridis)
library(sf)

# working directory
setwd("~/git/sdc.health_dev/Health Care Services/PCNA Measures/Check-up and Dental Visits")

# get county and census tract geographies
counties <- get_acs(
  geography = "county", 
  state = "VA",
  variables = "B19013_001",
  year = 2019,
  geometry = TRUE
)
counties <- counties %>% select(c("GEOID", "geometry"))

tracts <- get_acs(
  geography = "tract", 
  state = "VA",
  variables = "B19013_001",
  year = 2019,
  geometry = TRUE
)
tracts <- tracts %>% select(c("GEOID", "geometry"))

# load in the working data
dent_ct <- read_csv("data/distribution/va_ct_brfss_2018_percent_annual_dental_visit.csv")
dent_ct$geoid <- as.character(dent_ct$geoid)
dent_tr <- read_csv("data/distribution/va_tr_brfss_2018_percent_annual_dental_visit.csv")
dent_tr$geoid <- as.character(dent_tr$geoid)
check_ct <- read_csv("data/distribution/va_ct_brfss_2019_percent_annual_checkup.csv")
check_ct$geoid <- as.character(check_ct$geoid)
check_tr <- read_csv("data/distribution/va_tr_brfss_2019_percent_annual_checkup.csv")
check_tr$geoid <- as.character(check_tr$geoid)

# add geographies  to the measures
dent_ct <- left_join(dent_ct, counties, by=c("geoid" = "GEOID"))
check_ct <- left_join(check_ct, counties, by=c("geoid" = "GEOID"))

dent_tr <- left_join(dent_tr, tracts, by=c("geoid" = "GEOID"))
check_tr <- left_join(check_tr, tracts, by=c("geoid" = "GEOID"))

ggplot() +
  geom_sf(data = check_ct, aes(geometry=geometry, fill=`value`), lwd = 0) +
  scale_fill_viridis() + theme_bw() + 
  geom_sf(data= counties$geometry, fill = NA, colour = "white", lwd=0.5) + # add county boundaries
  xlab("longitude") + ylab("latitude") + 
  #scale_fill_viridis_c(limits = c(50, 100)) +
  labs(subtitle="Estimated Share of Virginians visited a doctor for a routine checkup within 2019", fill = "Percent") +
  theme(plot.subtitle = element_text(hjust = 0.5),
        axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank())
#ggsave("~/R/pcna/check_ct.png",height=4.5,width=8)

ggplot() +
  geom_sf(data = dent_ct, aes(geometry=geometry, fill=`value`), lwd = 0) +
  scale_fill_viridis() + theme_bw() + 
  geom_sf(data= counties$geometry, fill = NA, colour = "white", lwd=0.5) + # add county boundaries
  xlab("longitude") + ylab("latitude") + 
  #scale_fill_viridis_c(limits = c(50, 100)) +
  labs(subtitle="Estimated Share of Virginians reporting they have visited a dentist or dental clinic within 2019", fill = "Percent") +
  theme(plot.subtitle = element_text(hjust = 0.5),
        axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank())
#ggsave("~/R/pcna/dent_ct.png",height=4.5,width=8)

ggplot() +
  geom_sf(data = check_tr, aes(geometry=geometry, fill=`value`), lwd = 0) +
  scale_fill_viridis() + theme_bw() + 
  geom_sf(data= tracts$geometry, fill = NA, colour = "white", lwd=0.5) + # add county boundaries
  xlab("longitude") + ylab("latitude") + 
  #scale_fill_viridis_c(limits = c(50, 100)) +
  labs(subtitle="Estimated Share of Virginians visited a doctor for a routine checkup within 2019", fill = "Percent") +
  theme(plot.subtitle = element_text(hjust = 0.5),
        axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank())
#ggsave("~/R/pcna/check_tr.png",height=4.5,width=8)

ggplot() +
  geom_sf(data = dent_tr, aes(geometry=geometry, fill=`value`), lwd = 0) +
  scale_fill_viridis() + theme_bw() + 
  geom_sf(data= tracts$geometry, fill = NA, colour = "white", lwd=0.5) + # add county boundaries
  xlab("longitude") + ylab("latitude") + 
  #scale_fill_viridis_c(limits = c(50, 100)) +
  labs(subtitle="Estimated Share of Virginians reporting they have visited a dentist or dental clinic within 2019", fill = "Percent") +
  theme(plot.subtitle = element_text(hjust = 0.5),
        axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank())
#ggsave("~/R/pcna/dent_tr.png",height=4.5,width=8)
