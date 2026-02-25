library(sf)
#> Linking to GEOS 3.9.1, GDAL 3.4.3, PROJ 7.2.1; sf_use_s2() is TRUE

# initialize starting point
p_init <- c("lon" = -76.73775043228096, "lat" = 38.243928310389464) |> 
  sf::st_point() |> 
  sf::st_geometry()

# define crs
sf::st_crs(p_init) <- "epsg:4326"

# transform from geodetic to projected crs; here: WGS 84 / UTM 31 N
coords <- sf::st_transform(p_init, "epsg:32631") |> 
  sf::st_coordinates()

# define dimensions, create grid
y <- 14
x <- 16

cellsize <- 15000

pts <- data.frame("lat" = rep(coords[, 2], x * y) + (seq(0, by = cellsize, length.out = y) |> rep(each = x)),
                  "lon" = seq(coords[, 1], by = cellsize, length.out = x) |> rep(y)) |> 
  sf::st_as_sf(coords = c("lon", "lat"), crs = "epsg:32631")


# inspect result
plot(pts)
plot(sf::st_transform(p_init, "epsg:32631"), col = "red", add = TRUE)

sf::st_transform(pts$geometry[1], "epsg:4326")
sf::st_transform(pts$geometry[25], "epsg:4326")


va <- sf::st_transform(tigris::counties(state = "VA", cb = TRUE), "epsg:4326")
md <- sf::st_transform(tigris::counties(state = "MD", cb = TRUE), "epsg:4326")


plot(st_geometry(md[md$NAME %in% c("Charles", "Prince George's", "Montgomery", "Frederick"),]))
plot(st_geometry(va[va$NAME %in% c("Fairfax", "Arlington", "Loudoun", "Prince William"),]), add = T)
plot(sf::st_transform(pts[1]$geometry, "epsg:4326"), add = T)

nrc_gmap_coords <- sf::st_coordinates(sf::st_transform(pts$geometry, "epsg:4326"))
colnames(nrc_gmap_coords) <- c("long", "lat")
data.table::fwrite(nrc_gmap_coords, "Health Care Services/nrc_gmap_coords.csv")
