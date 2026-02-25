library(readr)
library(fuzzyjoin)
library(viridis)

# working directory
setwd("~/git/sdc.health_dev/Health Care Services/Health Professionals/VA Graduates")

# load working data
grads <- read_csv("data/working/out_grad.csv")
profs <- read_csv("data/working/out_profs.csv")
undergrads <- read_csv("data/working/out_under.csv")
two_year <- read_csv("data/working/out_two.csv")

#################
# MAPS
#################

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
counties$GEOID <-  as.numeric(counties$GEOID)

undergrads <- left_join(undergrads, counties, by = c("geoid" = "GEOID"))
grads <- left_join(grads, counties, by = c("geoid" = "GEOID"))
profs <- left_join(profs, counties, by = c("geoid" = "GEOID"))
two_year <- left_join(two_year, counties, by = c("geoid" = "GEOID"))

ggplot() +
  geom_sf(data = undergrads, aes(geometry=geometry, fill=`2019`), lwd = 0) +
  scale_fill_viridis() + theme_bw() + 
  geom_sf(data= counties, fill = NA, colour = "white", lwd=0.5) + # add county boundaries
  xlab("longitude") + ylab("latitude") + 
  labs(subtitle="Undergradute Degrees Awarded in Health Professions (4-year Private and Public) in 2019", fill = "Count") +
  theme(plot.subtitle = element_text(hjust = 0.5),
        axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank())
#ggsave("~/R/pcna/schev_va_graduates/all_undergrads.png",height=4.5,width=8)

ggplot() +
  geom_sf(data = grads, aes(geometry=geometry, fill=`2019`), lwd = 0) +
  scale_fill_viridis() + theme_bw() + 
  geom_sf(data= counties, fill = NA, colour = "white", lwd=0.5) + # add county boundaries
  xlab("longitude") + ylab("latitude") + 
  labs(subtitle="Graduate Degrees Awarded in Health Professions (4-year Private and Public) in 2019", fill = "Count") +
  theme(plot.subtitle = element_text(hjust = 0.5),
        axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank())
ggsave("~/R/pcna/schev_va_graduates/all_grads.png",height=4.5,width=8)

ggplot() +
  geom_sf(data = profs, aes(geometry=geometry, fill=`2019`), lwd = 0) +
  scale_fill_viridis() + theme_bw() + 
  geom_sf(data= counties, fill = NA, colour = "white", lwd=0.5) + # add county boundaries
  xlab("longitude") + ylab("latitude") + 
  labs(subtitle="First Professional Degrees Awarded in Health Professions in 2019", fill = "Count") +
  theme(plot.subtitle = element_text(hjust = 0.5),
        axis.line=element_blank(),
        axis.text.x=element_blank(),
        axis.text.y=element_blank(),
        axis.ticks=element_blank(),
        axis.title.x=element_blank(),
        axis.title.y=element_blank())
#ggsave("~/R/pcna/schev_va_graduates/all_profs.png",height=4.5,width=8)


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
#ggsave("~/R/pcna/schev_va_graduates/all_two.png",height=4.5,width=8)
