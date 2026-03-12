# Spatial Assessment of Push-Pull Technology (PPT) in Malawi

[![R](https://www.r-project.org/logo/Rlogo.png)](https://www.r-project.org/)  

**Quinto Juma Meltus*, Elfatih Abdel-Rahman, Komi Agboka Mensah, Rachel Awuor Owino, Takemore Chagomoka, and Thomas Dubois**  
International Centre of Insect Physiology and Ecology ([icipe](https://www.icipe.org/)), Nairobi, Kenya  
*Corresponding author: [jmeltus@icipe.org](mailto:jmeltus@icipe.org)*  

---

## Overview

This repository contains **R scripts** for evaluating the suitability of conventional (1st generation) and climate-smart (2nd generation) Push-Pull Technology (PPT) for maize pest management in Malawi using a **spatial species distribution modeling framework**.  

The workflow integrates:

1. **Species occurrence data acquisition** – Downloading global occurrence records from GBIF (e.g., stemborers, fall armyworm, and companion crops such as *Desmodium spp.*).  
2. **Species Distribution Modeling (SDM)** – Using the `sdm` R package and MaxEnt algorithm to predict environmental suitability for maize pests and PPT companion plants.  
3. **Validation with PPT demonstration plots** – Using georeferenced field data (104 sites across Malawi) to assess predictive performance.  
4. **Raster preprocessing** – Cropping, masking, and resampling environmental predictors (climatic, edaphic, and landscape variables) to Malawi-specific grids.  


This framework supports strategic prioritization of PPT adoption in Malawi and broader SSA.

---

## Repository Structure
