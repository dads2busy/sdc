-- !preview conn=DBI::dbConnect(RSQLite::SQLite())

-- Virginia
select *
into dc_working.va_tile_bgtrcthd_intersect_2019_2021
from(
(select a.*, b."GEOID",
st_area(st_intersection(a.geometry , b.geometry))/st_area(a.geometry) as tile_percent,
st_area(st_intersection(b.geometry , a.geometry))/st_area(b.geometry) as bg_percent
from dc_working.va_tile_ookla_2019_2021 as a, dc_geographies.va_acs_2019_block_groups as b
where a.year = 2019 AND ST_Intersects(a.geometry, b.geometry))
UNION
(select a.*, b."GEOID",
st_area(st_intersection(a.geometry , b.geometry))/st_area(a.geometry) as tile_percent,
st_area(st_intersection(b.geometry , a.geometry))/st_area(b.geometry) as bg_percent
from dc_working.va_tile_ookla_2019_2021 as a, dc_geographies.va_acs_2019_census_tracts as b
where a.year = 2019 AND ST_Intersects(a.geometry, b.geometry))
UNION
(select a.*, b."GEOID",
st_area(st_intersection(a.geometry , b.geometry))/st_area(a.geometry) as tile_percent,
st_area(st_intersection(b.geometry , a.geometry))/st_area(b.geometry) as bg_percent
from dc_working.va_tile_ookla_2019_2021 as a, dc_geographies.va_acs_2019_counties as b
where a.year = 2019 AND ST_Intersects(a.geometry, b.geometry))
UNION
(select a.*, b."GEOID",
st_area(st_intersection(a.geometry , b.geometry))/st_area(a.geometry) as tile_percent,
st_area(st_intersection(b.geometry , a.geometry))/st_area(b.geometry) as bg_percent
from dc_working.va_tile_ookla_2019_2021 as a, dc_geographies.va_acs_2020_block_groups as b
where a.year > 2019 AND ST_Intersects(a.geometry, b.geometry))
UNION
(select a.*, b."GEOID",
st_area(st_intersection(a.geometry , b.geometry))/st_area(a.geometry) as tile_percent,
st_area(st_intersection(b.geometry , a.geometry))/st_area(b.geometry) as bg_percent
from dc_working.va_tile_ookla_2019_2021 as a, dc_geographies.va_acs_2020_census_tracts as b
where a.year > 2019 AND ST_Intersects(a.geometry, b.geometry))
UNION
(select a.*, b."GEOID",
st_area(st_intersection(a.geometry , b.geometry))/st_area(a.geometry) as tile_percent,
st_area(st_intersection(b.geometry , a.geometry))/st_area(b.geometry) as bg_percent
from dc_working.va_tile_ookla_2019_2021 as a, dc_geographies.va_acs_2020_counties as b
where a.year > 2019 AND ST_Intersects(a.geometry, b.geometry))
UNION
(select a.*, b.geoid as "GEOID",
st_area(st_intersection(a.geometry , b.geometry))/st_area(a.geometry) as tile_percent,
st_area(st_intersection(b.geometry , a.geometry))/st_area(b.geometry) as bg_percent
from dc_working.va_tile_ookla_2019_2021 as a, dc_geographies.va_vhd_2020_health_districts as b
where ST_Intersects(a.geometry, b.geometry))
) t

-- DC
select *
into dc_working.dc_tile_bgtrct_intersect_2019_2021
from(
(select a.*, b."GEOID",
st_area(st_intersection(a.geometry , b.geometry))/st_area(a.geometry) as tile_percent,
st_area(st_intersection(b.geometry , a.geometry))/st_area(b.geometry) as bg_percent
from dc_working.dc_tile_ookla_2019_2021 as a, dc_geographies.dc_acs_2019_block_groups as b
where a.year = 2019 AND ST_Intersects(a.geometry, b.geometry))
UNION
(select a.*, b."GEOID",
st_area(st_intersection(a.geometry , b.geometry))/st_area(a.geometry) as tile_percent,
st_area(st_intersection(b.geometry , a.geometry))/st_area(b.geometry) as bg_percent
from dc_working.dc_tile_ookla_2019_2021 as a, dc_geographies.dc_acs_2019_census_tracts as b
where a.year = 2019 AND ST_Intersects(a.geometry, b.geometry))
UNION
(select a.*, b."GEOID",
st_area(st_intersection(a.geometry , b.geometry))/st_area(a.geometry) as tile_percent,
st_area(st_intersection(b.geometry , a.geometry))/st_area(b.geometry) as bg_percent
from dc_working.dc_tile_ookla_2019_2021 as a, dc_geographies.dc_acs_2019_counties as b
where a.year = 2019 AND ST_Intersects(a.geometry, b.geometry))
UNION
(select a.*, b."GEOID",
st_area(st_intersection(a.geometry , b.geometry))/st_area(a.geometry) as tile_percent,
st_area(st_intersection(b.geometry , a.geometry))/st_area(b.geometry) as bg_percent
from dc_working.dc_tile_ookla_2019_2021 as a, dc_geographies.dc_acs_2020_block_groups as b
where a.year > 2019 AND ST_Intersects(a.geometry, b.geometry))
UNION
(select a.*, b."GEOID",
st_area(st_intersection(a.geometry , b.geometry))/st_area(a.geometry) as tile_percent,
st_area(st_intersection(b.geometry , a.geometry))/st_area(b.geometry) as bg_percent
from dc_working.dc_tile_ookla_2019_2021 as a, dc_geographies.dc_acs_2020_census_tracts as b
where a.year > 2019 AND ST_Intersects(a.geometry, b.geometry))
UNION
(select a.*, b."GEOID",
st_area(st_intersection(a.geometry , b.geometry))/st_area(a.geometry) as tile_percent,
st_area(st_intersection(b.geometry , a.geometry))/st_area(b.geometry) as bg_percent
from dc_working.dc_tile_ookla_2019_2021 as a, dc_geographies.dc_acs_2020_counties as b
where a.year > 2019 AND ST_Intersects(a.geometry, b.geometry))
) t

-- Maryland
select *
into dc_working.md_tile_bgtrct_intersect_2019_2021
from(
(select a.*, b."GEOID",
st_area(st_intersection(a.geometry , b.geometry))/st_area(a.geometry) as tile_percent,
st_area(st_intersection(b.geometry , a.geometry))/st_area(b.geometry) as bg_percent
from dc_working.md_tile_ookla_2019_2021 as a, dc_geographies.md_acs_2019_block_groups as b
where a.year = 2019 AND ST_Intersects(a.geometry, b.geometry))
UNION
(select a.*, b."GEOID",
st_area(st_intersection(a.geometry , b.geometry))/st_area(a.geometry) as tile_percent,
st_area(st_intersection(b.geometry , a.geometry))/st_area(b.geometry) as bg_percent
from dc_working.md_tile_ookla_2019_2021 as a, dc_geographies.md_acs_2019_census_tracts as b
where a.year = 2019 AND ST_Intersects(a.geometry, b.geometry))
UNION
(select a.*, b."GEOID",
st_area(st_intersection(a.geometry , b.geometry))/st_area(a.geometry) as tile_percent,
st_area(st_intersection(b.geometry , a.geometry))/st_area(b.geometry) as bg_percent
from dc_working.md_tile_ookla_2019_2021 as a, dc_geographies.md_acs_2019_counties as b
where a.year = 2019 AND ST_Intersects(a.geometry, b.geometry))
UNION
(select a.*, b."GEOID",
st_area(st_intersection(a.geometry , b.geometry))/st_area(a.geometry) as tile_percent,
st_area(st_intersection(b.geometry , a.geometry))/st_area(b.geometry) as bg_percent
from dc_working.md_tile_ookla_2019_2021 as a, dc_geographies.md_acs_2020_block_groups as b
where a.year > 2019 AND ST_Intersects(a.geometry, b.geometry))
UNION
(select a.*, b."GEOID",
st_area(st_intersection(a.geometry , b.geometry))/st_area(a.geometry) as tile_percent,
st_area(st_intersection(b.geometry , a.geometry))/st_area(b.geometry) as bg_percent
from dc_working.md_tile_ookla_2019_2021 as a, dc_geographies.md_acs_2020_census_tracts as b
where a.year > 2019 AND ST_Intersects(a.geometry, b.geometry))
UNION
(select a.*, b."GEOID",
st_area(st_intersection(a.geometry , b.geometry))/st_area(a.geometry) as tile_percent,
st_area(st_intersection(b.geometry , a.geometry))/st_area(b.geometry) as bg_percent
from dc_working.md_tile_ookla_2019_2021 as a, dc_geographies.md_acs_2020_counties as b
where a.year > 2019 AND ST_Intersects(a.geometry, b.geometry))
) t


-- Combine All
select *
into dc_working.vamddc_tile_bgtrcthd_intersect_2019_2021
from (
(select * from dc_working.va_tile_bgtrcthd_intersect_2019_2021)
UNION
(select * from dc_working.dc_tile_bgtrct_intersect_2019_2021)
UNION
(select * from dc_working.md_tile_bgtrct_intersect_2019_2021)
) t


-- fix column name
ALTER TABLE dc_working.vamddc_tile_bgtrcthd_intersect_2019_2021 
RENAME COLUMN bg_percent TO geo_percent


-- get yearly geography broadband measures
select *
into dc_working.vamddc_broadband_speeds_2019_2021
from (
(select "GEOID" as geoid, year, 'avg_down_using_devices' as measure, round(avg(avg_d_kbps)/1000, 2) as value, NULL as moe 
from dc_working.vamddc_tile_bgtrcthd_intersect_2019_2021
where quarter = 4
group by ("GEOID", year)
order by ("GEOID", year))
UNION
(select "GEOID" as geoid, year, 'avg_up_using_devices' as measure, round(avg(avg_u_kbps)/1000, 2) as value, NULL as moe 
from dc_working.vamddc_tile_bgtrcthd_intersect_2019_2021
where quarter = 4
group by ("GEOID", year)
order by ("GEOID", year))
) t
order by (geoid, year, measure)



