# Health Degrees offered bi MSI Institutions in Virginia and land-grant universities 
# List of MSI 

# packages 
library(readr)
library(dplyr)
library(tidyr)


# your working directory 
setwd("~/git/sdc.health_dev/Health Care Services/Health Professionals/MSI Institutions/")

norfolk <- read_csv("/Users/avagutshall/Desktop/folder/sdc.health_dev/Health Care Services/Health Professionals/MSI Institutions/data/original/norfolk.csv")
hampton <- read_csv("/Users/avagutshall/Desktop/folder/sdc.health_dev/Health Care Services/Health Professionals/MSI Institutions/data/original/hampton.csv")
northern <- read_csv("/Users/avagutshall/Desktop/folder/sdc.health_dev/Health Care Services/Health Professionals/MSI Institutions/data/original/northern.csv")
vastate <- read_csv("/Users/avagutshall/Desktop/folder/sdc.health_dev/Health Care Services/Health Professionals/MSI Institutions/data/original/vastate.csv")
vaunion <- read_csv("/Users/avagutshall/Desktop/folder/sdc.health_dev/Health Care Services/Health Professionals/MSI Institutions/data/original/vaunion.csv")
vtech <- read_csv("/Users/avagutshall/Desktop/folder/sdc.health_dev/Health Care Services/Health Professionals/MSI Institutions/data/original/vtech.csv")
msi <- do.call("rbind", list(norfolk, hampton, northern, vastate, vaunion, vtech))

# get the list of all health degrees
list_degrees <- read_csv("/Users/avagutshall/Desktop/folder/sdc.health_dev/Health Care Services/Health Professionals/VA Graduates/docs/list_of_health_professional_degrees.csv")

msi_health <- msi %>% filter(`CIP Code` %in% list_degrees$`CIP Code`)
write_csv(msi_health, "/Users/avagutshall/Downloads/msi_health_degrees.csv")

# upload completed degrees
norfolk23 <- read_csv("/Users/avagutshall/Desktop/folder/sdc.health_dev/Health Care Services/Health Professionals/MSI Institutions/data/original/norfolk_23.csv")
hampton23 <- read_csv("/Users/avagutshall/Desktop/folder/sdc.health_dev/Health Care Services/Health Professionals/MSI Institutions/data/original/hampton_23.csv")
northern23 <- read_csv("/Users/avagutshall/Desktop/folder/sdc.health_dev/Health Care Services/Health Professionals/MSI Institutions/data/original/northern_23.csv")
vastate23 <- read_csv("/Users/avagutshall/Desktop/folder/sdc.health_dev/Health Care Services/Health Professionals/MSI Institutions/data/original/vastate_23.csv")
vaunion23 <- read_csv("/Users/avagutshall/Desktop/folder/sdc.health_dev/Health Care Services/Health Professionals/MSI Institutions/data/original/vaunion_23.csv")
vtech23 <- read_csv("/Users/avagutshall/Desktop/folder/sdc.health_dev/Health Care Services/Health Professionals/MSI Institutions/data/original/vtech_23.csv")
msi23 <- do.call("rbind", list(norfolk23, hampton23, northern23, vastate23, vaunion23, vtech23))
msi23 <- msi23 %>% select(c(Institution, Year, `Program...4`, `Total Awards`)) %>%
  separate(`Program...4`, into=c("program_name", "cip"), sep = ", \\(", extra = "drop", fill = "right")
msi23$cip <- gsub("\\)", "", msi23$cip)
msi23_health <- msi23 %>% filter(cip %in% msi_health$`CIP Code`)

msi_prog_awards23 <- msi23_health %>% group_by(Year, cip) %>%
  summarise(degree_awards = sum(`Total Awards`))

msi_health_degrees <- msi23_health %>% group_by(`Institution`,`Year`) %>%
  summarise(degree_awards = sum(`Total Awards`))
write_csv(msi_health_degrees, "/Users/avagutshall/Downloads/msi23_health_degrees_awarded.csv")

