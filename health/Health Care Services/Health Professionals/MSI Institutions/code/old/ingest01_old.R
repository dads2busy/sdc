# Health Degrees offered bi MSI Institutions in Virginia and land-grant universities 
# List of MSI 

# packages 
library(readr)

# your working directory 
setwd("~/git/sdc.health_dev/Health Care Services/Health Professionals/MSI Institutions/")

norfolk <- read_csv("data/original/norfolk.csv")
hampton <- read_csv("data/original/hampton.csv")
northern <- read_csv("data/original/northern.csv")
vastate <- read_csv("data/original/vastate.csv")
vaunion <- read_csv("data/original/vaunion.csv")
vtech <- read_csv("data/original/vtech.csv")
msi <- do.call("rbind", list(norfolk, hampton, northern, vastate, vaunion, vtech))

# get the list of all health degrees
list_degrees <- read_csv("~/git/sdc.health_dev/Health Care Services/Health Professionals/VA Graduates/docs/list_of_health_professional_degrees.csv")

msi_health <- msi %>% filter(`CIP Code` %in% list_degrees$`CIP Code`)
write_csv(msi_health, "data/working/msi_health_degrees.csv")

# upload completed degrees
norfolk21 <- read_csv("data/original/norfolk_21.csv")
hampton21 <- read_csv("data/original/hampton_21.csv")
northern21 <- read_csv("data/original/northern_21.csv")
vastate21 <- read_csv("data/original/vastate_21.csv")
vaunion21 <- read_csv("data/original/vaunion_21.csv")
vtech21 <- read_csv("data/original/vtech_21.csv")
msi21 <- do.call("rbind", list(norfolk21, hampton21, northern21, vastate21, vaunion21, vtech21))
msi21 <- msi21 %>% select(c(Institution, Year, `Program...4`, `Total Awards`)) %>%
  separate(`Program...4`, into=c("program_name", "cip"), sep = ", \\(", extra = "drop", fill = "right")
msi21$cip <- gsub("\\)", "", msi21$cip)
msi21_health <- msi21 %>% filter(cip %in% msi_health$`CIP Code`)

msi_prog_awards21 <- msi21_health %>% group_by(Year, cip) %>%
  summarise(degree_awards = sum(`Total Awards`))

msi_health_degrees <- msi21_health %>% group_by(`Institution`,`Year`) %>%
  summarise(degree_awards = sum(`Total Awards`))
write_csv(msi_health_degrees, "data/working/msi21_health_degrees_awarded.csv")

