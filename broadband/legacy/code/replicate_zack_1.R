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

# block groups
va_bg_2019 <- tigris::block_groups(state = "VA", year = 2019, cb = T)
va_bg_2019_wgs <- st_transform(va_bg_2019, crs = 4326)
st_write(get_db_conn(), obj = va_bg_2019_wgs, layer = c("dc_geographies", "va_acs_2019_block_groups"))

dc_bg_2019 <- tigris::block_groups(state = "DC", year = 2019, cb = T)
dc_bg_2019_wgs <- st_transform(dc_bg_2019, crs = 4326)
st_write(get_db_conn(), obj = dc_bg_2019_wgs, layer = c("dc_geographies", "dc_acs_2019_block_groups"))

md_bg_2019 <- tigris::block_groups(state = "MD", year = 2019, cb = T)
md_bg_2019_wgs <- st_transform(md_bg_2019, crs = 4326)
st_write(get_db_conn(), obj = md_bg_2019_wgs, layer = c("dc_geographies", "md_acs_2019_block_groups"))


va_bg_2020 <- tigris::block_groups(state = "VA", year = 2020, cb = T)
va_bg_2020_wgs <- st_transform(va_bg_2020, crs = 4326)
st_write(get_db_conn(), obj = va_bg_2020_wgs, layer = c("dc_geographies", "va_acs_2020_block_groups"))

dc_bg_2020 <- tigris::block_groups(state = "DC", year = 2020, cb = T)
dc_bg_2020_wgs <- st_transform(dc_bg_2020, crs = 4326)
st_write(get_db_conn(), obj = dc_bg_2020_wgs, layer = c("dc_geographies", "dc_acs_2020_block_groups"))

md_bg_2020 <- tigris::block_groups(state = "MD", year = 2020, cb = T)
md_bg_2020_wgs <- st_transform(md_bg_2020, crs = 4326)
st_write(get_db_conn(), obj = md_bg_2020_wgs, layer = c("dc_geographies", "md_acs_2020_block_groups"))

# tracts
va_tr_2019 <- tigris::tracts(state = "VA", year = 2019, cb = T)
va_tr_2019_wgs <- st_transform(va_tr_2019, crs = 4326)
st_write(get_db_conn(), obj = va_tr_2019_wgs, layer = c("dc_geographies", "va_acs_2019_census_tracts"))

dc_tr_2019 <- tigris::tracts(state = "DC", year = 2019, cb = T)
dc_tr_2019_wgs <- st_transform(dc_tr_2019, crs = 4326)
st_write(get_db_conn(), obj = dc_tr_2019_wgs, layer = c("dc_geographies", "dc_acs_2019_census_tracts"))

md_tr_2019 <- tigris::tracts(state = "MD", year = 2019, cb = T)
md_tr_2019_wgs <- st_transform(md_tr_2019, crs = 4326)
st_write(get_db_conn(), obj = md_tr_2019_wgs, layer = c("dc_geographies", "md_acs_2019_census_tracts"))


va_tr_2020 <- tigris::tracts(state = "VA", year = 2020, cb = T)
va_tr_2020_wgs <- st_transform(va_tr_2020, crs = 4326)
st_write(get_db_conn(), obj = va_tr_2020_wgs, layer = c("dc_geographies", "va_acs_2020_census_tracts"))

dc_tr_2020 <- tigris::tracts(state = "DC", year = 2020, cb = T)
dc_tr_2020_wgs <- st_transform(dc_tr_2020, crs = 4326)
st_write(get_db_conn(), obj = dc_tr_2020_wgs, layer = c("dc_geographies", "dc_acs_2020_census_tracts"))

md_tr_2020 <- tigris::tracts(state = "MD", year = 2020, cb = T)
md_tr_2020_wgs <- st_transform(md_tr_2020, crs = 4326)
st_write(get_db_conn(), obj = md_tr_2020_wgs, layer = c("dc_geographies", "md_acs_2020_census_tracts"))

# counties
va_ct_2019 <- tigris::counties(state = "VA", year = 2019, cb = T)
va_ct_2019_wgs <- st_transform(va_ct_2019, crs = 4326)
st_write(get_db_conn(), obj = va_ct_2019_wgs, layer = c("dc_geographies", "va_acs_2019_counties"))

dc_ct_2019 <- tigris::counties(state = "DC", year = 2019, cb = T)
dc_ct_2019_wgs <- st_transform(dc_ct_2019, crs = 4326)
st_write(get_db_conn(), obj = dc_ct_2019_wgs, layer = c("dc_geographies", "dc_acs_2019_counties"))

md_ct_2019 <- tigris::counties(state = "MD", year = 2019, cb = T)
md_ct_2019_wgs <- st_transform(md_ct_2019, crs = 4326)
st_write(get_db_conn(), obj = md_ct_2019_wgs, layer = c("dc_geographies", "md_acs_2019_counties"))


va_ct_2020 <- tigris::counties(state = "VA", year = 2020, cb = T)
va_ct_2020_wgs <- st_transform(va_ct_2020, crs = 4326)
st_write(get_db_conn(), obj = va_ct_2020_wgs, layer = c("dc_geographies", "va_acs_2020_counties"))

dc_ct_2020 <- tigris::counties(state = "DC", year = 2020, cb = T)
dc_ct_2020_wgs <- st_transform(dc_ct_2020, crs = 4326)
st_write(get_db_conn(), obj = dc_ct_2020_wgs, layer = c("dc_geographies", "dc_acs_2020_counties"))

md_ct_2020 <- tigris::counties(state = "MD", year = 2020, cb = T)
md_ct_2020_wgs <- st_transform(md_ct_2020, crs = 4326)
st_write(get_db_conn(), obj = md_ct_2020_wgs, layer = c("dc_geographies", "md_acs_2020_counties"))

# VA health districts
va_hd_2020 <- st_read("https://raw.githubusercontent.com/uva-bi-sdad/sdc.geographies/main/VA/State%20Geographies/Health%20Districts/2020/data/distribution/va_geo_vhd_2020_health_districts.geojson")
st_write(get_db_conn(), obj = va_hd_2020, layer = c("dc_geographies", "va_vhd_2020_health_districts"))



# go to SQL