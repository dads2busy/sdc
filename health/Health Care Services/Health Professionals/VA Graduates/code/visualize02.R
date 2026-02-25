# Creates maps of number of graduates in health professions by health district 

library(readr)
library(viridis)
library(sf)

# working directory
setwd("~/git/sdc.health_dev/Health Care Services/Health Professionals/VA Graduates")

######################################
# CREATE HEALTH DISTRICTS GEOGRAPHIES
######################################

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
#counties$GEOID <-  as.numeric(counties$GEOID)

# add health districts
# connect to database
con <- dbConnect(PostgreSQL(), 
                 dbname = "sdad",
                 host = "postgis1", 
                 port = 5432, 
                 user = "hc2cc",
                 password = "hc2cchc2cc")
# read in health districts
health_district <- dbGetQuery(con, "SELECT * FROM dc_common.va_hdct_sdad_2021_health_district_counties")
dbDisconnect(con)

# merge health districts with county geographies
health_district <- left_join(health_district, counties, by=c("geoid_county"="GEOID"))
# create health districts 
health_district <- health_district %>% group_by(geoid, region_name) %>% 
  summarise(geometry = st_union(geometry))
 
# load working data
grads <- read_csv("data/working/grad_hd.csv")
profs <- read_csv("data/working/profs_hd.csv")
undergrads <- read_csv("data/working/under_hd.csv")
two_year <- read_csv("data/working/two_hd.csv")

# add geometries to data
undergrads <- left_join(undergrads, health_district[,c("region_name","geometry")], by = c("region_name" = "region_name"))
grads <- left_join(grads, health_district[,c("region_name","geometry")], by = c("region_name" = "region_name"))
profs <- left_join(profs, health_district[,c("region_name","geometry")], by = c("region_name" = "region_name"))
two_year <- left_join(two_year, health_district[,c("region_name","geometry")], by = c("region_name" = "region_name"))

ggplot() +
  geom_sf(data = undergrads, aes(geometry=geometry, fill=`2019`), lwd = 0) +
  scale_fill_viridis() + theme_bw() + 
  geom_sf(data= health_district$geometry, fill = NA, colour = "white", lwd=0.5) + # add county boundaries
  xlab("longitude") + ylab("latitude") + 
  labs(subtitle="Undergradute Degrees Awarded in Health Professions (4-year Private and Public) in 2019", fill = "Count") +
  theme(plot.subtitle = element_text(hjust = 0.5),
        axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank())
#ggsave("~/R/pcna/schev_va_graduates/undergrads_hd.png",height=4.5,width=8)

ggplot() +
  geom_sf(data = grads, aes(geometry=geometry, fill=`2019`), lwd = 0) +
  scale_fill_viridis() + theme_bw() + 
  geom_sf(data= health_district$geometry, fill = NA, colour = "white", lwd=0.5) + # add county boundaries
  xlab("longitude") + ylab("latitude") + 
  labs(subtitle="Graduate Degrees Awarded in Health Professions (4-year Private and Public) in 2019", fill = "Count") +
  theme(plot.subtitle = element_text(hjust = 0.5),
        axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank())
#ggsave("~/R/pcna/schev_va_graduates/grads_hd.png",height=4.5,width=8)

ggplot() +
  geom_sf(data = profs, aes(geometry=geometry, fill=`2019`), lwd = 0) +
  scale_fill_viridis() + theme_bw() + 
  geom_sf(data= health_district$geometry, fill = NA, colour = "white", lwd=0.5) + # add county boundaries
  xlab("longitude") + ylab("latitude") + 
  labs(subtitle="First Professional Degrees Awarded in Health Professions in 2019", fill = "Count") +
  theme(plot.subtitle = element_text(hjust = 0.5),
        axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank())
#ggsave("~/R/pcna/schev_va_graduates/profs_hd.png",height=4.5,width=8)

ggplot() +
  geom_sf(data = two_year, aes(geometry=geometry, fill=`2019`), lwd = 0) +
  scale_fill_viridis() + theme_bw() + 
  geom_sf(data= health_district$geometry, fill = NA, colour = "white", lwd=0.5) + # add county boundaries
  xlab("longitude") + ylab("latitude") + 
  labs(subtitle="2-year Degrees Awarded in Health Professions in 2019", fill = "Count") +
  theme(plot.subtitle = element_text(hjust = 0.5),
        axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank())
#ggsave("~/R/pcna/schev_va_graduates/two_year_hd.png",height=4.5,width=8)
