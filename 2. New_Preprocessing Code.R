# =========================================
# Generic Raster Processing and Extraction Pipeline
# Author: Quinto Juma Meltus
# Purpose: Preprocess environmental rasters, align, mask, crop, resample, 
#          and extract values to species occurrence points for modeling
# =========================================

# ------------------------------
# 1. Install required packages (only if not installed)
# ------------------------------
packages <- c("raster", "rasterVis", "gdalUtils", "rgdal", "ggplot2", "sf", "terra", "stars")
new_packages <- packages[!(packages %in% installed.packages()[, "Package"])]
if (length(new_packages)) install.packages(new_packages, dependencies = TRUE)

# ------------------------------
# 2. Load libraries
# ------------------------------
library(raster)
library(rasterVis)
library(gdalUtils)
library(rgdal)
library(ggplot2)
library(sf)
library(terra)
library(stars)

# ------------------------------
# 3. Set working directory (optional)
# ------------------------------
#setwd("C:/GIS/Project_Folder")
list.files()

# ------------------------------
# 4. Define Coordinate Reference System (CRS)
# ------------------------------
# Example: UTM Zone 36N, WGS84 datum
sr <- CRS("+proj=utm +zone=36 +datum=WGS84 +units=m +north +no_defs")

# ------------------------------
# 5. Load species occurrence shapefile (Desmodium spp. points)
# ------------------------------
species_shp <- shapefile("path_to/Desmodium_points.shp")  # Replace with your shapefile
species_shp <- spTransform(species_shp, sr)
plot(species_shp, main = "Species Occurrences")

# ------------------------------
# 6. Load country or region shapefile
# ------------------------------
region_shp <- shapefile("path_to/region_boundary.shp")  # Replace with your boundary
region_shp <- spTransform(region_shp, sr)
plot(region_shp)
plot(species_shp, add = TRUE)

# ------------------------------
# 7. Load base mask raster (defines extent/resolution)
# ------------------------------
maskFile <- raster("path_to/mask_file.tif")  # Base raster for alignment
maskFile <- projectRaster(maskFile, crs = sr)
plot(maskFile)

# ------------------------------
# 8. Process environmental raster layers
# ------------------------------
inputdir_rasters <- "path_to/input_rasters"  # Folder with all input rasters
outdir_rasters <- "path_to/output_rasters"  # Folder to save processed rasters
raster_files <- list.files(inputdir_rasters, pattern = "*.tif$", full.names = TRUE, recursive = TRUE)

# Stack all rasters for processing
raster_stack <- stack(raster_files)

# Loop through rasters: project, crop, mask, and save
for (i in seq_along(raster_files)) {
  r <- raster(raster_files[i])
  
  # Project raster to match mask CRS
  r_prj <- projectRaster(r, maskFile, method = "ngb")  # "ngb" for categorical; change to "bilinear" for continuous
  
  # Crop and mask
  r_crop <- crop(r_prj, maskFile)
  r_mask <- mask(r_crop, maskFile)
  
  # Save output
  outname <- paste0(names(raster_stack[[i]]), ".tif")
  writeRaster(r_mask, filename = file.path(outdir_rasters, outname), overwrite = TRUE)
  
  # Cleanup
  rm(r, r_prj, r_crop, r_mask)
  gc()
}

# ------------------------------
# 9. Load additional covariates (e.g., TWI, NDVI, LST) and resample
# ------------------------------
covariates <- list(
  "twi.tif", "ndvi.tif", "ndwi.tif", "lst.tif", "rh.tif", "temp.tif"
)  # Replace with your raster names

# Create a base raster for resampling
base_raster <- maskFile  # Use the mask or any reference raster
resampled_stack <- stack()

for (cov in covariates) {
  r <- raster(file.path("path_to/covariates", cov))
  r_prj <- projectRaster(r, crs = sr)
  r_res <- resample(r_prj, base_raster, method = "ngb")  # Use "bilinear" for continuous variables
  resampled_stack <- stack(resampled_stack, r_res)
}

plot(resampled_stack)

# ------------------------------
# 10. Extract raster values to species occurrence points
# ------------------------------
species_values <- raster::extract(resampled_stack, species_shp)

# Combine extracted values with species attributes
species_data <- cbind(species_shp, species_values)

# Save to CSV for modeling
write.csv(species_data, "Desmodium_EnvironmentalData.csv", row.names = FALSE)
cat("Species environmental data extraction complete.\n")

# ------------------------------
# 11. Optional: Apply multiplicative factor to raster
# ------------------------------
# Example: scale raster by factor for standardization
factor <- 14  # Change as needed
r_scaled <- resampled_stack[[1]] * factor
writeRaster(r_scaled, "path_to/output_scaled_raster.tif", overwrite = TRUE)
cat("Raster scaling complete.\n")