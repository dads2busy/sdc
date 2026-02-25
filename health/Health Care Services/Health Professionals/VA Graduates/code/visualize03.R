# Creats maps of AHEC reagions by the number of graduates in health professions

library(readr)
library(viridis)
library(sf)

# working directory
setwd("~/git/sdc.health_dev/Health Care Services/Health Professionals/VA Graduates")

######################################
# CREATE AHEC REGIONS GEOGRAPHIES
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
counties <- counties %>% select(c("GEOID", "NAME", "geometry"))

blue_ridge <- c("Albemarle", "Augusta", "Bath", "Clarke", "Culpeper", "Fauquier", 
                "Frederick", "Greene", "Highland", "Loudoun", "Louisa", "Madison", 
                "Nelson", "Orange", "Page", "Rappahannock", "Rockbridge", "Rockingham", 
                "Shenandoah", "Warren", "Fluvanna",
                "Buena Vista", "Charlottesville", "Harrisonburg", 
                "Lexington", "Staunton", "Waynesboro", "Winchester")

capital <- c("Charles", "Chesterfield", "Colonial Heights", "Goochland", "Hanover", 
             "Henrico", "New Kent", "Powhatan", "Richmond city")

north_virginia <- c("Arlington", "Fairfax", "Loudoun", "Prince William", 
                    "Alexandria", "Fairfax", "Falls Church", "Manassas", "Manassas Park")

eastern_virginia <- c("Accomack", "Isle of Wight", "James City", "Northampton", "Southampton",
                      "York", "Chesapeake", "Franklin", "Hampton", "Newport News", 
                      "Norfolk", "Poquoson", "Portsmouth", "Suffolk", "Virginia Beach", 
                      "Williamsburg")

rappahannock <- c("Caroline", "Essex", "Fredericksburg", "Gloucester", "King George",
                  "King and Queen", "King William", "Lancaster", "Mathews", "Middlesex", 
                  "Northumberland", "Richmond County", "Spotsylvania", "Stafford", "Westmoreland")

south_central <- c("Amherst", "Appomattox", "Bedford", "Campbell", "Franklin", "Henry", 
                   "Patrick", "Pittsylvania", "Bedford", "Danville", "Lynchburg", "Martinsville")

southside <- c("Amelia", "Brunswick", "Buckingham", "Charlotte", "Cumberland", "Dinwiddie",
               "Greensville", "Halifax", "Lunenburg", "Mecklenburg", "Nottoway", 
               "Prince Edward", "Prince George", "Surry", "Sussex", "Emporia", "Hopewell", "Petersburg")

southwest <- c("Alleghany", "Bland", "Botetourt", "Buchanan", "Carroll", "Craig", 
               "Dickenson", "Floyd", "Giles", "Grayson", "Lee", "Montgomery", "Pulaski", 
               "Roanoke", "Russell", "Scott", "Smyth", "Tazewell", "Washington", "Wise",
               "Wythe", "Bristol", "Covington", "Galax", "Norton", "Radford", "Salem")

counties$NAME[grepl(paste(blue_ridge, collapse="|"),counties$NAME) == T] <- "Blue Ridge"
counties$NAME[grepl(paste(capital, collapse="|"),counties$NAME) == T] <- "Capital"
counties$NAME[grepl(paste(north_virginia, collapse="|"),counties$NAME) == T] <- "Northern Virginia"
counties$NAME[grepl(paste(eastern_virginia, collapse="|"),counties$NAME) == T] <- "Eastern Virginia"
counties$NAME[grepl(paste(rappahannock, collapse="|"),counties$NAME) == T] <- "Rappahannock"
counties$NAME[grepl(paste(south_central, collapse="|"),counties$NAME) == T] <- "South Central"
counties$NAME[grepl(paste(southside, collapse="|"),counties$NAME) == T] <- "Southside"
counties$NAME[grepl(paste(southwest, collapse="|"),counties$NAME) == T] <- "Southwest"

counties <- counties %>% 
  mutate(GEOID = case_when(
    NAME == "Blue Ridge" ~ "51_ahec_01",
    NAME == "Capital" ~ "51_ahec_02",
    NAME == "Northern Virginia" ~ "51_ahec_03",
    NAME == "Eastern Virginia" ~ "51_ahec_04",
    NAME == "Rappahannock" ~ "51_ahec_05",
    NAME == "South Central" ~ "51_ahec_06",
    NAME == "Southside" ~ "51_ahec_07",
    NAME == "Southwest" ~ "51_ahec_08")) %>%
  group_by(NAME, GEOID) %>%
  summarise(geometry = st_union(geometry))

# load working data
grads <- read_csv("data/working/grad_ahec.csv")
profs <- read_csv("data/working/profs_ahec.csv")
undergrads <- read_csv("data/working/under_ahec.csv")
two_year <- read_csv("data/working/two_ahec.csv")

# add geometries to data
undergrads <- left_join(undergrads, counties[, c("GEOID", "geometry")], by = c("geoid" = "GEOID"))
grads <- left_join(grads, counties[,c("GEOID", "geometry")], by = c("geoid" = "GEOID"))
profs <- left_join(profs, counties[,c("GEOID", "geometry")], by = c("geoid" = "GEOID"))
two_year <- left_join(two_year, counties[,c("GEOID", "geometry")], by = c("geoid" = "GEOID"))

ggplot() +
  geom_sf(data = undergrads, aes(geometry=geometry, fill=`2019`), lwd = 0) +
  scale_fill_viridis() + theme_bw() + 
  geom_sf(data= counties$geometry, fill = NA, colour = "white", lwd=0.5) + # add county boundaries
  xlab("longitude") + ylab("latitude") + 
  labs(subtitle="Undergradute Degrees Awarded in Health Professions (4-year Private and Public) in 2019", fill = "Count") +
  theme(plot.subtitle = element_text(hjust = 0.5),
        axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank())
#ggsave("~/R/pcna/schev_va_graduates/undergrads_ahec.png",height=4.5,width=8)

ggplot() +
  geom_sf(data = grads, aes(geometry=geometry, fill=`2019`), lwd = 0) +
  scale_fill_viridis() + theme_bw() + 
  geom_sf(data= counties$geometry, fill = NA, colour = "white", lwd=0.5) + # add county boundaries
  xlab("longitude") + ylab("latitude") + 
  labs(subtitle="Graduate Degrees Awarded in Health Professions (4-year Private and Public) in 2019", fill = "Count") +
  theme(plot.subtitle = element_text(hjust = 0.5),
        axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank())
#ggsave("~/R/pcna/schev_va_graduates/grads_ahec.png",height=4.5,width=8)

ggplot() +
  geom_sf(data = profs, aes(geometry=geometry, fill=`2019`), lwd = 0) +
  scale_fill_viridis() + theme_bw() + 
  geom_sf(data= counties$geometry, fill = NA, colour = "white", lwd=0.5) + # add county boundaries
  xlab("longitude") + ylab("latitude") + 
  labs(subtitle="First Professional Degrees Awarded in Health Professions in 2019", fill = "Count") +
  theme(plot.subtitle = element_text(hjust = 0.5),
        axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank())
#ggsave("~/R/pcna/schev_va_graduates/profs_ahec.png",height=4.5,width=8)

ggplot() +
  geom_sf(data = two_year, aes(geometry=geometry, fill=`2019`), lwd = 0) +
  scale_fill_viridis() + theme_bw() + 
  geom_sf(data= counties, fill = NA, colour = "white", lwd=0.5) + # add county boundaries
  xlab("longitude") + ylab("latitude") + 
  labs(subtitle="2-year Degrees Awarded in Health Professions in 2019", fill = "Count") +
  theme(plot.subtitle = element_text(hjust = 0.5),
        axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank())
#ggsave("~/R/pcna/schev_va_graduates/two_ahec.png",height=4.5,width=8)
