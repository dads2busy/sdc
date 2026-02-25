library(readr)

#import names of all data files
datafiles <- list.files(path = "./Microdata/QCEW Benchmark/data/original")


#switch type of data files to list
listdatafiles <- as.list(datafiles)


#create dataframe with column names
firstdata <- read_csv("./Microdata/QCEW Benchmark/data/original/2010.annual 11 Agriculture, forestry, fishing and hunting.csv.xz")
fairfaxdata <- firstdata[0,]
rowcount = 0 

#bind Fairfax data to fulldata for each data file
for (i in listdatafiles) {
  filepath <- paste("./Microdata/QCEW Benchmark/data/original/", i, sep = "")
  data <- read_csv(filepath)
  newdata <- data[which(data$area_fips=='51059'),]
  rowcount <- rowcount + nrow(newdata)
  fairfaxdata <- rbind(fairfaxdata, newdata)
}

#save csv
write.csv(fairfaxdata, "./Microdata/QCEW Benchmark/data/fairfaxdata.csv.xz")

# read csv
fairfaxdata <- read.csv("./Microdata/QCEW Benchmark/data/fairfaxdata.csv.xz")

# sum variable by year and industry code
fairfax_year <- aggregate(fairfaxdata["annual_avg_emplvl"],by=fairfaxdata["year"],sum)
fairfax_industry <- aggregate(fairfaxdata["annual_avg_emplvl"],by=fairfaxdata["industry_code"],sum)

# extract unique industry codes to obtain industry titles
fairfaxdata_subset <- fairfaxdata[!duplicated(fairfaxdata$industry_code), ]

fairfax_industry["industry_title"] <- 0

for (i in 1:length(fairfax_industry["industry_code"])){
  for (k in 1:length(fairfaxdata_subset["industry_code"])){
    if (fairfaxdata_subset["industry_code"][k] == fairfax_industry["industry_code"][i]){
      fairfax_industry["industry_title"][i] <- fairfaxdata_subset["industry_title"][k]
    }
  }
}

fairfax_industry["area_fips"] <- "51059"
fairfax_industry["area_title"] <- "Fairfax County, Virginia"
fairfax_year["area_fips"] <- "51059"
fairfax_year["area_title"] <- "Fairfax County, Virginia"

fairfax_year <- fairfax_year[, c(3, 4, 1, 2)]
fairfax_industry <- fairfax_industry[, c(4, 5, 1, 3, 2)]

colnames(fairfax_year)[colnames(fairfax_year) == "annual_avg_emplvl"] = "total_employment"
colnames(fairfax_industry)[colnames(fairfax_industry) == "annual_avg_emplvl"] ="total_employment"

write.csv(fairfax_year, "./Microdata/QCEW Benchmark/data/fairfaxdata_year.csv.xz")
write.csv(fairfax_industry, "./Microdata/QCEW Benchmark/data/fairfaxdata_industry.csv.xz")

fairfax_year_industry <- aggregate(fairfaxdata["annual_avg_emplvl"],by=fairfaxdata[c("industry_code", "year")],sum)
fairfax_year_industry["area_fips"] <- "51059"
fairfax_year_industry["area_title"] <- "Fairfax County, Virginia"
fairfax_year_industry["industry_title"] = 0
fairfax_year_industry["industry_title"] <- fairfax_industry["industry_title"]
fairfax_year_industry <- fairfax_year_industry[, c(4, 5, 2, 1, 6, 3)]

colnames(fairfax_year_industry)[colnames(fairfax_year_industry) == "annual_avg_emplvl"] ="total_employment"

write.csv(fairfax_year_industry, "./Microdata/QCEW Benchmark/data/fairfaxdata_year_industry.csv.xz")


