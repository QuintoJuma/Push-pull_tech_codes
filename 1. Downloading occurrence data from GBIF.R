# =========================================
# Generic GBIF Occurrence Data Downloader
# Author: Quinto Juma Meltus
# Purpose: Download, clean, filter, and export species occurrence data
# =========================================

# ------------------------------
# 1. Install required packages (only if not already installed)
# ------------------------------
packages <- c("rgbif", "leaflet", "viridis", "dplyr", "lubridate", "sp")
new_packages <- packages[!(packages %in% installed.packages()[, "Package"])]
if (length(new_packages)) install.packages(new_packages)

# ------------------------------
# 2. Load libraries
# ------------------------------
library(rgbif)      # Access GBIF occurrence data
library(leaflet)    # Interactive mapping
library(viridis)    # Color palettes for maps
library(dplyr)      # Data manipulation
library(lubridate)  # Date filtering
library(sp)         # Spatial data handling

# ------------------------------
# 3. Define user inputs
# ------------------------------
species_name <- "Busseola fusca"  # Replace with any species
output_file <- "Global_Species_Occurrences.csv" # Replace with desired path
year_range <- c(1900, 2025)                      # Filter occurrence years
max_records <- 10000                             # Maximum records to download

# ------------------------------
# 4. Download occurrence data from GBIF
# ------------------------------
occ_data <- occ_search(
  scientificName = species_name,
  limit = max_records
)

# ------------------------------
# 5. Inspect raw data structure
# ------------------------------
names(occ_data)
head(occ_data$data)
unique(occ_data$data$genus)

# ------------------------------
# 6. Select relevant columns and clean data
# ------------------------------
occ_clean <- occ_data$data %>%
  dplyr::select(
    scientificName,
    decimalLatitude,
    decimalLongitude,
    country,
    occurrenceStatus,
    year
  ) %>%
  dplyr::rename(
    species = scientificName,
    lat = decimalLatitude,
    long = decimalLongitude,
    Occurrence = occurrenceStatus
  ) %>%
  dplyr::filter(complete.cases(.)) %>% # Remove rows with missing data
  dplyr::distinct()                    # Remove duplicates

# ------------------------------
# 7. Filter data by year range
# ------------------------------
occ_filtered <- occ_clean %>%
  filter(year >= year_range[1] & year <= year_range[2])

# ------------------------------
# 8. Preview filtered data
# ------------------------------
print(dim(occ_filtered))
head(occ_filtered)

# ------------------------------
# 9. Convert to spatial object for mapping or spatial analysis
# ------------------------------
coordinates(occ_filtered) <- ~long + lat
plot(occ_filtered, main = paste("Occurrences of", species_name))

# Optional: plot original data too
coordinates(occ_clean) <- ~long + lat
plot(occ_clean, col = "blue", main = paste("Raw data for", species_name))

# ------------------------------
# 10. Export cleaned occurrence data
# ------------------------------
write.csv(occ_filtered, output_file, row.names = FALSE)
cat(paste("Data exported to", output_file))