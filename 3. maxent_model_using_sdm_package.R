# =========================================
# Generic Species Distribution Modeling Pipeline
# Example species: Napier grass
# Author: Quinto Juma Meltus
# Purpose: Process species occurrence data and environmental predictors
#          and fit MaxEnt models with configurable parameters
# =========================================

# ------------------------------
# 1. Install required packages (only if not installed)
# ------------------------------
packages <- c('terra', 'sp', 'raster', 'rgdal', 'dismo', 'rJava', 'sdm', 'gbm', 'vip', 'pdp', 'boot', 'dplyr', 'PresenceAbsence', 'ggpubr', 'RColorBrewer', 'quickPlot', 'foreign')
new_packages <- packages[!(packages %in% installed.packages()[, "Package"])]
if(length(new_packages)) install.packages(new_packages, dependencies = TRUE)

# ------------------------------
# 2. Load libraries
# ------------------------------
library(terra)
library(sp)
library(raster)
library(rgdal)
library(dismo)
library(rJava)
library(sdm)
library(dplyr)

# ------------------------------
# 3. Load species occurrence data
# ------------------------------
species_file <- "path_to/Napier_grass_occurrences.shp"  # Replace with your shapefile
species <- shapefile(species_file)

# Define CRS (WGS84)
sr <- CRS("+proj=longlat +datum=WGS84 +no_defs")
species <- spTransform(species, sr)

# Plot species occurrences
plot(species, main = "Napier Grass Occurrences")

# ------------------------------
# 4. Load environmental predictors
# ------------------------------
raster_file <- "path_to/environmental_predictors.tif"  # Multi-band raster
preds <- brick(raster_file)  # If multiple bands stacked
plot(preds[[1]], main = "First Predictor Layer")
plot(species, add = TRUE)

# ------------------------------
# 5. Prepare SDM data
# ------------------------------
# Background points: 1500 random points; remove duplicates
sdm_data <- sdmData(
  formula = Occ ~ ., 
  train = species, 
  predictors = preds, 
  bg = list(n = 1500, method = 'gRandom', remove = TRUE)
)

# ------------------------------
# 6. Check available methods in sdm
# ------------------------------
getmethodNames()

# ------------------------------
# 7. Fit MaxEnt model with options
# ------------------------------
# Configure regularization and feature types via maxent.args
maxent_args <- c(
  "betamultiplier=1.5",     # Regularization multiplier (change as needed)
  "linear=true",            # Use linear features
  "quadratic=true",         # Use quadratic features
  "product=false",
  "threshold=false",
  "hinge=true"
)

start_time <- Sys.time()
maxent_model <- sdm(
  Occ ~ ., 
  data = sdm_data, 
  methods = c('maxent'), 
  replication = "cv", 
  test.percent = 30, 
  cv.folds = 5,
  maxent.args = maxent_args
)
end_time <- Sys.time()
cat("Modeling time:", end_time - start_time, "\n")

# ------------------------------
# 8. Predict across environmental layers
# ------------------------------
predicted_raster <- predict(
  maxent_model, 
  newdata = preds, 
  filename = "path_to/output/NapierGrass_prediction.tif", 
  overwrite = TRUE
)
plot(predicted_raster, main = "Predicted Suitability for Napier Grass")

# ------------------------------
# 9. Parallel prediction (optional)
# ------------------------------
pred_parallel <- predict(
  maxent_model, 
  newdata = preds, 
  filename = "path_to/output/NapierGrass_prediction_parallel.tif",
  parallelSetting = list(ncore = 2),
  overwrite = TRUE
)
plot(pred_parallel)

# ------------------------------
# 10. Ensemble modeling (optional)
# ------------------------------
ensemble_pred <- ensemble(
  maxent_model, 
  newdata = preds, 
  filename = "path_to/output/NapierGrass_ensemble.tif",
  setting = list(method = 'weighted', stat = 'AUC'),
  overwrite = TRUE
)
plot(ensemble_pred, main = "Ensemble Prediction")

# ------------------------------
# 11. Variable importance
# ------------------------------
varImp <- getVarImp(maxent_model)
print(varImp)
plot(varImp)

# ------------------------------
# 12. Model evaluation
# ------------------------------
rmse_vals <- getEvaluation(maxent_model, stat = 'RMSE')
print(rmse_vals)

# ------------------------------
# 13. Save evaluation metrics
# ------------------------------
write.csv(rmse_vals, "path_to/output/NapierGrass_model_evaluation.csv", row.names = FALSE)
cat("SDM workflow complete. Predictions and evaluations saved.\n")