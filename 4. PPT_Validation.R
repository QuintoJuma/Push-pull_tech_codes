# =========================================
# Presence/Absence Analysis by PPT Generation
# Author: Quinto Juma Meltus
# Purpose: Calculate number of presence/absence points and percentage predicted presence
#          separately for Generation 1 (Gen_1) and Generation 2 (Gen_2) PPT
# =========================================

# ----------------------------------
# 1. Load required libraries
# ----------------------------------
library(dplyr)
library(readr)

# ----------------------------------
# 2. Load CSV with extracted raster values
# ----------------------------------
# Ensure your CSV has columns: PPTGen, Gen_1, Gen_2
list.files()
df <- read_csv("2_both_Gens.csv")

# Preview
head(df)

# ----------------------------------
# 3. Function to count presence/absence and calculate percentage presence
# ----------------------------------
# Customize presence/absence categories if needed
count_presence <- function(values) {
  # Define presence/absence categories (example: 1-2 = absence, 3-5 = presence)
  n_presence <- sum(values %in% 3:5, na.rm = TRUE)
  n_absence  <- sum(values %in% 1:2, na.rm = TRUE)
  n_na       <- sum(is.na(values))
  total      <- length(values)
  
  perc_presence <- round(n_presence / (n_presence + n_absence) * 100, 1)
  
  data.frame(
    Total_Points = total,
    Points_Absence = n_absence,
    Points_Presence = n_presence,
    Points_NA = n_na,
    Percentage_Predicted_Presence = perc_presence
  )
}

# ----------------------------------
# 4. Filter by PPT Generation and apply function
# ----------------------------------
results <- bind_rows(
  Gen_1 = count_presence(df %>% filter(PPTGen == 1) %>% pull(Gen_1)),
  Gen_2 = count_presence(df %>% filter(PPTGen == 2) %>% pull(Gen_2)),
  .id = "PPT_Generation"
)

# ----------------------------------
# 5. Print results
# ----------------------------------
print(results)

# ----------------------------------
# 6. Save results to CSV
# ----------------------------------
write.csv(results, "PPT_presence_percentage_by_generation.csv", row.names = FALSE)
cat("Presence/absence summary saved to 'PPT_presence_percentage_by_generation.csv'\n")