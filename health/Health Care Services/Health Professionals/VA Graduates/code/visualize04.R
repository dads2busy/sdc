# Create a bubble map of the number of graduates in health professions from MSI and Land-grant Universities 

library(readr)
library(viridis)

# working directory
setwd("~/git/sdc.health_dev/Health Care Services/Health Professionals/VA Graduates")

# load in the list of all universities
institutes <- read_csv("~/git/sdc.health_dev/Health Care Services/Health Professionals/VA Graduates/data/working/College Degrees.csv")

# load in working data
msi21 <- read_csv("data/working/msi21_health_degrees_awarded.csv")

institutes <- institutes %>% filter(Institution %in% msi21$Institution) %>%
  subset(Year == 2019)
msi21 <- left_join(msi21,institutes[,c("Institution", "long", "lat")] )
msi21$long[msi21$Institution == "Northern Virginia Community College"] <- -77.2365; msi21$lat[msi21$Institution == "Northern Virginia Community College"] <- 38.8332

# get va counties geographies
counties <- get_acs(
  geography = "county", 
  state = "VA",
  variables = "B19013_001",
  year = 2019,
  geometry = TRUE
)

# add geometries to data
counties <- counties %>% select(c("GEOID", "geometry"))

ggplot() +
  geom_sf(data = counties$geometry, fill="grey", lwd = 0.1) +
  geom_text( data=msi21 %>% arrange(degree_awards), aes(x=long, y=lat, label=Institution), size=3, nudge_y = 0.15, check_overlap = T) +
  geom_point(data= msi21, aes(x=long, y=lat, size=degree_awards, color=degree_awards), alpha=0.9) +
  theme_void()+ guides( colour = guide_legend())
ggsave("~/R/pcna/schev_va_graduates/msi21_awards.png",height=4.5,width=8)
