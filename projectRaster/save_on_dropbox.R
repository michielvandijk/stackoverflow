# ========================================================================================
# Subject:  Save files on dropbox so others can check
# Author:   Michiel van Dijk
# Contact:  michiel.vandijk@wur.nl
# ========================================================================================

# Packages
library(raster)
library(sf)
library(gdalUtilities)
library(tictoc)

# Load map
path <- "C:/Users/dijk158/OneDrive - Wageningen University & Research/Acquisition/2021_protein_transition/data/crop_type"
input <- file.path(path, "EUCROPMAP_2018.tif")
r <- raster(input)

# Get Luxembourg polygon
poly <- st_as_sf(getData(name = "GADM", country = "LUX", level = 2))

# Reproject
poly <- st_transform(poly, crs(r))

# select a province
poly <- poly %>%
  dplyr::filter(NAME_2 == "Vianden")

# Crop
r_crop <- crop(r, poly)
plot(r_crop)
plot(poly$geometry, add = T)

# Save on dropbox
db_path <- "C:/Users/dijk158/Dropbox/stackExchange"
writeRaster(r_crop, file.path(db_path, "r_crop.tif"))

# recode raster to select maize (maize code = 216)
# 22655.12 sec!
tic()
s <- calc(r, fun=function(x){x[x != 216] <- 0; return(x)})
s <- calc(r, fun=function(x){x[x == 216] <- 1; return(x)})
toc()

# Calculate average for a raster of 250x250m
# This part is not implemented as the reclassification in the previous step failed.
output <- file.path("c:/temp/maize_share_250m.tif")
gdalUtils::gdalwarp(input, output,  tr = c(250,250), r = "average", verbose = TRUE)

plot(raster(output))