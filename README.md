# 🌱 Spatial Assessment of Push-Pull Technology (PPT) in Malawi

[![R](https://www.r-project.org/logo/Rlogo.png)](https://www.r-project.org/)  
[![GitHub](https://img.shields.io/badge/GitHub-Repository-blue)](https://github.com/YourUsername)  

**Authors:** Quinto Juma Meltus*, Elfatih Abdel-Rahman, Komi Agboka Mensah, Rachel Awuor Owino, Takemore Chagomoka, Thomas Dubois  
**Institution:** International Centre of Insect Physiology and Ecology ([icipe](https://www.icipe.org/)), Nairobi, Kenya  
*Corresponding author: [jmeltus@icipe.org](mailto:jmeltus@icipe.org)*  

---

## 📖 Overview

This repository contains **R scripts** used to provide suitability layers for the evaluation of **conventional (1st generation) and climate-smart (2nd generation) PPT** for maize pest management in Malawi using a **species distribution modeling (SDM)-MaxEnt framework**.  

Workflow integrates:  

- 🌍 **Species occurrence data acquisition:** Download pest and companion crop occurrences from GBIF  
- 🌿 **Species Distribution Modeling:** MaxEnt using `sdm` package  
- 📊 **Validation:** 104 georeferenced PPT demonstration plots in Malawi  
- 🗺️ **Raster preprocessing:** Cropping, masking, resampling environmental predictors (climatic, edaphic, landscape)

---

## 📁 Repository Structure
