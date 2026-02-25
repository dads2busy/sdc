library(readr)

#import names of all data files
datafiles <- list.files(path = "./Microdata/QCEW Benchmark/data/original")

#switch type of data files to list
listdatafiles <- as.list(datafiles)

#save xz version of data and remove original csv
for (i in listdatafiles){
  filepath <- paste("./Microdata/QCEW Benchmark/data/original/", i, sep = "")
  newfilepath <- paste("./Microdata/QCEW Benchmark/data/original/", i, ".xz", sep = "")
  data <- read_csv(filepath)
  write_csv(data, xzfile(newfilepath))
  file.remove(filepath)
}


