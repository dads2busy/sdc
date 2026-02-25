# TRAFFIC FATALITIES

for (year in c(2016:2020)){
  url <- paste0("https://static.nhtsa.gov/nhtsa/downloads/FARS/", year, "/National/FARS", year, "NationalCSV.zip")
  destfile <- paste0("./Safety/data/original/FARS", year, "NationalCSV.csv")
  download.file(url, destfile)
}

# TRAFFIC ACCIDENTS

# Each row corresponds to a single accident; the variable FATALS indicates the number of fatalities.
# Each row corresponds to a single accident; the variable HARM_EVNAME indicates whether a pedestrian or a pedalcyclist was involved
