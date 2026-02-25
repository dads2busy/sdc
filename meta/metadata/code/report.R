library(rvest)
#library(tidyverse)
library(stringr)
library(qdapRegex)
library(dplyr)
library(tidyr)

sdad_url <- "https://github.com/uva-bi-sdad/"
#blob <- "/blob/main"
raw <- "/raw/main"

# MEASURES AND PATHS TABLE

p <- read_html("https://uva-bi-sdad.github.io/sdc.all_dev//tests/test_known_measures.html") %>%
  html_element("body") %>%
  html_elements("p") %>% html_text() %>%
  str_squish() %>%
  tibble() %>%
  mutate(measure = rm_between(., "{", "}", extract=TRUE))  %>%
  mutate(path = rm_between(., "Path:", "$", extract=TRUE, fixed = FALSE)) %>% select(-.) %>%
  separate_rows(measure, sep = ",") %>%
  mutate(measure = str_squish(measure)) %>% mutate(measure = str_replace_all(measure, "'", "")) %>%
  filter(!is.na(measure), measure != "NANA")

repos <- rm_between(p$path, "home/runner/work/sdc.all_dev/sdc.all_dev/data/", "/", extract = TRUE) %>% unlist()
p$repos <- repos
p$pattern <- paste0("/home/runner/work/sdc.all_dev/sdc.all_dev/data/", repos)

p <- p %>% mutate(path = str_remove(path, pattern)) %>%
  mutate(raw_path = paste0(sdad_url, repos, raw, path)) %>%
  mutate(raw_path = str_replace(raw_path, " ", "%20")) %>%
  mutate(path = str_remove(path, "^/"))

write.csv(p, "./data/ingest_report.csv", row.names = FALSE)

# GET MOST RECENT UPDATE TIME

# python script

# CONNECT TO MEASURE INFO
library(lubridate)

p <- read.csv("./data/ingest_github_report.csv") %>% mutate(update = as_datetime(update)) %>%
  filter(update > "2022-07-01")

library(foreach)
library(jsonlite)
url <- "https://raw.githubusercontent.com/uva-bi-sdad/sdc.all/main/data/measure_info_all.json"
json <- fromJSON(url)

list <- rbindlist.v2(json) %>% as.data.frame() %>% select(category, short_name, long_name, short_description, long_description, statement) %>% mutate(measure = names(json[lapply(json, class) == "list"])) %>% select(measure, short_name, short_description)

report <- p %>% left_join(list, by = "measure") %>%
  mutate(short_description = case_when(
    !is.na(short_description) ~ short_description,
    !is.na(short_name) ~ short_name,
    !is.na(measure) ~ measure
  )) %>% distinct() %>% select(short_description, raw_path) %>% filter(!is.na(short_description)) %>%
  mutate(short_description = str_squish(short_description)) #%>%
  filter(short_description != '')

readr::write_csv(report, "data_commons_report_info.csv")



