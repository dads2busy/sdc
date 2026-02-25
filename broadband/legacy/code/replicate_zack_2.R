library(RPostgreSQL)
library(tidycensus)
library(tigris)
library(sf)

# connect to database function
get_db_conn <-
  function(db_name = Sys.getenv("db_nam"),
           db_host = Sys.getenv("db_hst"),
           db_port = Sys.getenv("db_prt"),
           db_user = Sys.getenv("db_usr"),
           db_pass = Sys.getenv("db_pwd")) {
    RPostgreSQL::dbConnect(
      drv = RPostgreSQL::PostgreSQL(),
      dbname = db_name,
      host = db_host,
      port = db_port,
      user = db_user,
      password = db_pass
    )
  }

# create NCR broadband speeds file
ncr_dwn <- dbGetQuery(
  get_db_conn(),
  "
  select *
  from dc_working.vamddc_broadband_speeds_2019_2021
  where measure = 'avg_down_using_devices'
  and left(geoid, 5) IN ('51013', '51059', '51107', '51510', '51600', '51153', '51683', '51685', '51610', '11001', '24031', '24033', '24017', '24021')
  "
)

data.table::fwrite(ncr_dwn, "Wired/Accessibility/Average Download Speed/data/distribution/ncr_cttrbg_ookla_download_speeds.csv")

ncr_up <- dbGetQuery(
  get_db_conn(),
  "
  select *
  from dc_working.vamddc_broadband_speeds_2019_2021
  where measure = 'avg_up_using_devices'
  and left(geoid, 5) IN ('51013', '51059', '51107', '51510', '51600', '51153', '51683', '51685', '51610', '11001', '24031', '24033', '24017', '24021')
  "
)

data.table::fwrite(ncr_up, "Wired/Accessibility/Average Upload Speed/data/distribution/ncr_cttrbg_ookla_upload_speeds.csv")
