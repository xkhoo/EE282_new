# Resample all rasters to the same crs, extent and resolution

library(terra)

# Use the gdal processed long-term mean evi raster layer as a reference raster
# The npp, evi and land cover predictors were  
ref_raster <- rast("F:/UCI/production_predictors/EVI_2001_annual_mean.tif")
res(ref_raster)
ext(ref_raster)
crs(ref_raster)

#--------------------------
# Climate data (WorldClim)
#---------------------------

# Download bioclimatic variables from WorldClim (can be done in R)
clim_data_download <- worldclim_global(var = "bio", path = "F:/UCI/climate_predictors/", res = 0.5)

# After extracting the .gz files, read the raster tiff files
clim_data <- rast(list.files("F:/UCI/climate_predictors/climate_worldclim_1970_2000/wc2.1_30s/", pattern = "\\.tif$", full.names = TRUE))
clim_data_reproj <- project(clim_data, ref_raster, method = "bilinear")
writeRaster(clim_data_reproj, "F:/UCI/processed_predictors/resampled/climate_resampled.tif", overwrite = TRUE)

# Additional predictor rasters were downloaded separately from their source repositories, primarily using wget after locating the direct file URLs.
# For instance, the MODIS land cover product for year 2001: (wget -r -np -nH --cut-dirs=2 https://e4ftl01.cr.usgs.gov/MOTA/MCD12Q1.061/2001.01.01/)
# All MODIS products (EVI, NPP, and land cover) were processed on hpc due to the masking process which takes more than a day to run if running locally
# The processing is similar for all MODIS products, except for EVI (starting from masking -> mosaicking -> calculating annual mean -> calculating long-term mean)
# For instance, in the case of NPP, start with `code/script/gdal_mosaic_npp.sh` then run `npp.mean.R` by submitting `run_npp_mean.sh`
# EVI consists of montly composites, so I first generated annual mean using `evi.annual.mean.R` by submitting `run_evi_annual_mean.sh` 
# then long-term mean using `evi.longterm.mean.R` by submitting `run_evi_longterm_mean.sh`. 
AI <- rast("F:/UCI/climate_predictors/Global-AI_ET0_v3_annual/ai_v3_yr.tif")
AI_reproj <- project(AI, ref_raster, method = "bilinear")
AI_rescaled <- AI_reproj * 0.0001
writeRaster(AI_rescaled, "F:/UCI/processed_predictors/resampled/AI_resampled_rescaled.tif", overwrite = TRUE)

ET <- rast("F:/UCI/climate_predictors/Global-AI_ET0_v3_annual/et0_v3_yr.tif")
ET_reproj <- project(ET, ref_raster, method = "bilinear")
writeRaster(ET_reproj, "F:/UCI/processed_predictors/resampled/ET_resampled_latest.tif", overwrite = TRUE)


elevation <- rast("F:/UCI/topography_predictors/SRTM_GL1_srtm.vrt")
res(elevation)
elevation_reproj <- project(elevation, ref_raster, method = "bilinear")
writeRaster(elevation_reproj, "F:/UCI/processed_predictors/resampled/elevation_resampled.tif", overwrite = TRUE)


# Soil layers = surface (0-5cm) vs topsoil (0-30cm)
# Rasters from land bnu, extract only the surface soil (0-5cm)
TC <- rast("F:/UCI/soil_predictors/TC1/TC1.nc")
TC_reproj <- project(TC, ref_raster, method = "bilinear")
TC_topsoil <- TC_reproj[[1]]
TC_rescaled <- TC_topsoil * 0.01
writeRaster(TC_rescaled, "F:/UCI/processed_predictors/resampled/TC_resampled.tif", overwrite = TRUE)

TN <- rast("F:/UCI/soil_predictors/TN1/TN1.nc")
TN_reproj <- project(TN, ref_raster, method = "bilinear")
TN_topsoil <- TN_reproj[[1]]
TN_rescaled <- TN_topsoil * 0.01
writeRaster(TN_rescaled, "F:/UCI/processed_predictors/resampled/TN_resampled.tif", overwrite = TRUE)

TP <- rast("F:/UCI/soil_predictors/TP1/TP1.nc")
TP_reproj <- project(TP, ref_raster, method = "bilinear")
TP_topsoil <- TP_reproj[[1]]
TP_rescaled <- TP_topsoil * 0.0001
writeRaster(TP_rescaled, "F:/UCI/processed_predictors/resampled/TP_resampled.tif", overwrite = TRUE)

TK <- rast("F:/UCI/soil_predictors/TK1/TK1.nc")
TK_reproj <- project(TK, ref_raster, method = "bilinear")
TK_topsoil <- TK_reproj[[1]]
TK_rescaled <- TK_topsoil * 0.01
writeRaster(TK_rescaled, "F:/UCI/processed_predictors/resampled/TK_resampled.tif", overwrite = TRUE)

TS <- rast("F:/UCI/soil_predictors/TS1/TS1.nc")
TS_reproj <- project(TS, ref_raster, method = "bilinear")
TS_topsoil <- TS_reproj[[1]]
TS_rescaled <- TS_topsoil * 0.01
writeRaster(TS_rescaled, "F:/UCI/processed_predictors/resampled/TS_resampled.tif", overwrite = TRUE)

CACO3 <- rast("F:/UCI/soil_predictors/CACO31/CACO31.nc")
CACO3_reproj <- project(CACO3, ref_raster, method = "bilinear")
CACO3_topsoil <- CACO3_reproj[[1]]
CACO3_rescaled <- CACO3_topsoil * 0.01
writeRaster(CACO3_rescaled, "F:/UCI/processed_predictors/resampled/CACO3_resampled.tif", overwrite = TRUE)

BS <- rast("F:/UCI/soil_predictors/BS1/BS1.nc")
BS_reproj <- project(BS, ref_raster, method = "bilinear")
BS_topsoil <- BS_reproj[[1]]
BS_rescaled <- BS_reproj * 0.01
writeRaster(BS_rescaled, "F:/UCI/processed_predictors/resampled/BS_resampled.tif", overwrite = TRUE)

# Extract topsoil layer (0-30cm)
TC <- rast("F:/UCI/soil_predictors/TC1/TC1.nc")
res(TC)
#TC_reproj <- project(TC, ref_raster, method = "bilinear")
names(TC_reproj)
TC_topsoil <- (TC_reproj[[1]] * 6.80 + TC_reproj[[2]] * 6.05 + TC_reproj[[3]] * 9.90 + TC_reproj[[4]] * 7.25) / 30
TC_rescaled <- TC_topsoil * 0.01
writeRaster(TC_rescaled, "F:/UCI/processed_predictors/resampled/TC_resampled.topsoil.tif", overwrite = TRUE)


#TN <- rast("F:/UCI/soil_predictors/TN1/TN1.nc")
#TN_reproj <- project(TN, ref_raster, method = "bilinear")
TN_topsoil <- (TN_reproj[[1]] * 6.80 + TN_reproj[[2]] * 6.05 + TN_reproj[[3]] * 9.90 + TN_reproj[[4]] * 7.25) / 30
TN_rescaled <- TN_topsoil * 0.01
writeRaster(TN_rescaled, "F:/UCI/processed_predictors/resampled/TN_resampled.topsoil.tif", overwrite = TRUE)

#TP <- rast("F:/UCI/soil_predictors/TP1/TP1.nc")
#TP_reproj <- project(TP, ref_raster, method = "bilinear")
TP_topsoil <- (TP_reproj[[1]] * 6.80 + TP_reproj[[2]] * 6.05 + TP_reproj[[3]] * 9.90 + TP_reproj[[4]] * 7.25) / 30
TP_rescaled <- TP_topsoil * 0.0001
writeRaster(TP_rescaled, "F:/UCI/processed_predictors/resampled/TP_resampled.topsoil.tif", overwrite = TRUE)

#TK <- rast("F:/UCI/soil_predictors/TK1/TK1.nc")
#TK_reproj <- project(TK, ref_raster, method = "bilinear")
TK_topsoil <- (TK_reproj[[1]] * 6.80 + TK_reproj[[2]] * 6.05 + TK_reproj[[3]] * 9.90 + TK_reproj[[4]] * 7.25) / 30
TK_rescaled <- TK_topsoil * 0.01
writeRaster(TK_rescaled, "F:/UCI/processed_predictors/resampled/TK_resampled.topsoil.tif", overwrite = TRUE)

#TS <- rast("F:/UCI/soil_predictors/TS1/TS1.nc")
#TS_reproj <- project(TS, ref_raster, method = "bilinear")
TS_topsoil <- (TS_reproj[[1]] * 6.80 + TS_reproj[[2]] * 6.05 + TS_reproj[[3]] * 9.90 + TS_reproj[[4]] * 7.25) / 30
TS_rescaled <- TS_topsoil * 0.01
writeRaster(TS_rescaled, "F:/UCI/processed_predictors/resampled/TS_resampled.topsoil.tif", overwrite = TRUE)

#CACO3 <- rast("F:/UCI/soil_predictors/CACO31/CACO31.nc")
#CACO3_reproj <- project(CACO3, ref_raster, method = "bilinear")
CACO3_topsoil <- (CACO3_reproj[[1]] * 6.80 + CACO3_reproj[[2]] * 6.05 + CACO3_reproj[[3]] * 9.90 + CACO3_reproj[[4]] * 7.25) / 30
CACO3_rescaled <- CACO3_topsoil * 0.01
writeRaster(CACO3_rescaled, "F:/UCI/processed_predictors/resampled/CACO3_resampled.topsoil.tif", overwrite = TRUE)

#BS <- rast("F:/UCI/soil_predictors/BS1/BS1.nc")
#BS_reproj <- project(BS, ref_raster, method = "bilinear")
BS_topsoil <- (BS_reproj[[1]] * 6.80 + BS_reproj[[2]] * 6.05 + BS_reproj[[3]] * 9.90 + BS_reproj[[4]] * 7.25) / 30
BS_rescaled <- BS_reproj * 0.01
writeRaster(BS_rescaled, "F:/UCI/processed_predictors/resampled/BS_resampled.topsoil.tif", overwrite = TRUE)

# Soil variables from SoilGrids
# Download all .tiff locally (wget -r -np -nH --cut-dirs=4 https://files.isric.org/soilgrids/latest/data/phh2o/0-5cm/mean/)
# Load the .vrt file (store .vrt file together with other downloaded tiff files)
# Rasters in 250m, need to rescale by *0.1, surface layer (0-5cm)
pH <- rast("F:/UCI/soil_predictors/pH/phh2o_0-5cm_mean.vrt")
pH_reproj <- project(pH, ref_raster, method = "bilinear")
pH_rescaled <- pH_reproj * 0.1
writeRaster(pH_rescaled, "F:/UCI/processed_predictors/resampled/pH_resampled.tif", overwrite = TRUE)

nitrogen <- rast("F:/UCI/soil_predictors/nitrogen/nitrogen_0-5cm_mean.vrt")
nitrogen_reproj <- project(nitrogen, ref_raster, method = "bilinear")
nitrogen_rescaled <- nitrogen_reproj * 0.1
writeRaster(nitrogen_rescaled, "F:/UCI/processed_predictors/resampled/nitrogen_resampled.tif", overwrite = TRUE)

bdod <- rast("F:/UCI/soil_predictors/bulk_density/bdod_0-5cm_mean.vrt")
bdod_reproj <- project(bdod, ref_raster, method = "bilinear")
bdod_rescaled <- bdod_reproj * 0.1
writeRaster(bdod_rescaled, "F:/UCI/processed_predictors/resampled/bdod_resampled.tif", overwrite = TRUE)

cec <- rast("F:/UCI/soil_predictors/Cation_exchange_capacity/cec_0-5cm_mean.vrt")
cec_reproj <- project(cec, ref_raster, method = "bilinear")
cec_rescaled <- cec_reproj * 0.1
writeRaster(cec_rescaled, "F:/UCI/processed_predictors/resampled/cec_resampled.tif", overwrite = TRUE)

clay <- rast("F:/UCI/soil_predictors/clay/clay_0-5cm_mean.vrt")
clay_reproj <- project(clay, ref_raster, method = "bilinear")
clay_rescaled <- clay_reproj * 0.1
writeRaster(clay_rescaled, "F:/UCI/processed_predictors/resampled/clay_resampled.tif", overwrite = TRUE)

ocd <- rast("F:/UCI/soil_predictors/Organic_carbon_density/ocd_0-5cm_mean.vrt")
ocd_reproj <- project(ocd, ref_raster, method = "bilinear")
ocd_rescaled <- ocd_reproj * 0.1
writeRaster(ocd_rescaled, "F:/UCI/processed_predictors/resampled/ocd_resampled.tif", overwrite = TRUE)

ocs <- rast("F:/UCI/soil_predictors/organic_carbon_stocks/ocs_0-30cm_mean.vrt")
ocs_reproj <- project(ocs, ref_raster, method = "bilinear")
ocs_rescaled <- ocs_reproj * 0.1
writeRaster(ocs_rescaled, "F:/UCI/processed_predictors/resampled/topsoil/ocs_resampled.topsoil.tif", overwrite = TRUE)

sand <- rast("F:/UCI/soil_predictors/sand/sand_0-5cm_mean.vrt")
sand_reproj <- project(sand, ref_raster, method = "bilinear")
sand_rescaled <- sand_reproj * 0.1
writeRaster(sand_rescaled, "F:/UCI/processed_predictors/resampled/sand_resampled.tif", overwrite = TRUE)

silt <- rast("F:/UCI/soil_predictors/silt/silt_0-5cm_mean.vrt")
silt_reproj <- project(silt, ref_raster, method = "bilinear")
silt_rescaled <- silt_reproj * 0.1
writeRaster(silt_rescaled, "F:/UCI/processed_predictors/resampled/silt_resampled.tif", overwrite = TRUE)

cfvo <- rast("F:/UCI/soil_predictors/coarse_fragments/cfvo_0-5cm_mean/")
cfvo_reproj <- project(cfvo, ref_raster, method = "bilinear")
cfvo_rescaled <- cfvo_reproj * 0.1
writeRaster(cfvo_rescaled, "F:/UCI/processed_predictors/resampled/cfvo_resampled.tif", overwrite = TRUE)

soil_bioclim <- rast(list.files("F:/UCI/soil_predictors/soil_bioclim/soil_bioclim_7134169/", pattern = "\\.tif$", full.names = TRUE)) 
soil_bioclim_reproj <- project(soil_bioclim, ref_raster, method = "bilinear")
clim_data_reproj <- project(clim_data, ref_raster, method = "bilinear")
writeRaster(clim_data_reproj, "F:/UCI/processed_predictors/resampled/climate_resampled.tif", overwrite = TRUE)

# Topsoil layer for soilgrid variables
# Load rasters of different depths
pH_0_5   <- rast("F:/UCI/soil_predictors/pH/phh2o_0-5cm_mean.vrt")
pH_5_15  <- rast("F:/UCI/soil_predictors/pH/phh2o_5-15cm_mean.vrt")
pH_15_30 <- rast("F:/UCI/soil_predictors/pH/phh2o_15-30cm_mean.vrt")
# Combine into depth-weighted average for 0–30 cm
pH_0_30 <- (5 * pH_0_5 + 10 * pH_5_15 + 15 * pH_15_30) / 30
writeRaster(pH_0_30, "F:/UCI/soil_predictors/pH/pH_0-30cm_combined.tif", overwrite = TRUE)
pH_0_30_reproj <- project(pH_0_30, ref_raster, method = "bilinear")
pH_0_30_rescaled <- pH_0_30_reproj * 0.1
writeRaster(pH_0_30_rescaled, "F:/UCI/processed_predictors/resampled/pH_resampled.topsoil.tif", overwrite = TRUE)

cec_0_5   <- rast("F:/UCI/soil_predictors/Cation_exchange_capacity/cec_0-5cm_mean.vrt")
cec_5_15  <- rast("F:/UCI/soil_predictors/Cation_exchange_capacity/cec_5-15cm_mean.vrt")
cec_15_30 <- rast("F:/UCI/soil_predictors/Cation_exchange_capacity/cec_15-30cm_mean.vrt")
cec_0_30 <- (5 * cec_0_5 + 10 * cec_5_15 + 15 * cec_15_30) / 30
writeRaster(cec_0_30, "F:/UCI/soil_predictors/Cation_exchange_capacity/cec_0-30cm_combined.tif", overwrite = TRUE)
cec_0_31 <- rast("F:/UCI/soil_predictors/Cation_exchange_capacity/cec_0-30cm_combined.tif")
cec_0_30_reproj <- project(cec_0_31, ref_raster, method = "bilinear")
cec_0_30_rescaled <- cec_0_30_reproj * 0.1
writeRaster(cec_0_30_rescaled, "F:/UCI/processed_predictors/resampled/cec_resampled.topsoil.tif", overwrite = TRUE)

bdod_0_5   <- rast("F:/UCI/soil_predictors/bulk_density/bdod_0-5cm_mean.vrt")
bdod_5_15  <- rast("F:/UCI/soil_predictors/bulk_density/bdod_5-15cm_mean.vrt")
bdod_15_30 <- rast("F:/UCI/soil_predictors/bulk_density/bdod_15-30cm_mean.vrt")
bdod_0_30 <- (5 * bdod_0_5 + 10 * bdod_5_15 + 15 * bdod_15_30) / 30
writeRaster(bdod_0_30, "F:/UCI/soil_predictors/bulk_density/bdod_0-30cm_combined.tif", overwrite = TRUE)
bdod_0_30_reproj <- project(bdod_0_30, ref_raster, method = "bilinear")
bdod_0_30_rescaled <- bdod_0_30_reproj * 0.1
writeRaster(bdod_0_30_rescaled, "F:/UCI/processed_predictors/resampled/bdod_resampled.topsoil.tif", overwrite = TRUE)

ocd_0_5   <- rast("F:/UCI/soil_predictors/Organic_carbon_density/ocd_0-5cm_mean.vrt")
ocd_5_15  <- rast("F:/UCI/soil_predictors/Organic_carbon_density/ocd_5-15cm_mean.vrt")
ocd_15_30 <- rast("F:/UCI/soil_predictors/Organic_carbon_density/ocd_15-30cm_mean.vrt")
ocd_0_30 <- (5 * ocd_0_5 + 10 * ocd_5_15 + 15 * ocd_15_30) / 30
writeRaster(ocd_0_30, "F:/UCI/soil_predictors/Organic_carbon_density/ocd_0-30cm_combined.tif", overwrite = TRUE)
ocd_0_30_reproj <- project(ocd_0_30, ref_raster, method = "bilinear")
ocd_0_30_rescaled <- ocd_0_30_reproj * 0.1
writeRaster(ocd_0_30_rescaled, "F:/UCI/processed_predictors/resampled/ocd_resampled.topsoil.tif", overwrite = TRUE)

soc_0_5   <- rast("F:/UCI/soil_predictors/soil_organic_carbon/soc_0-5cm_mean.vrt")
soc_5_15  <- rast("F:/UCI/soil_predictors/soil_organic_carbon/soc_5-15cm_mean.vrt")
soc_15_30 <- rast("F:/UCI/soil_predictors/soil_organic_carbon/soc_15-30cm_mean.vrt")
soc_0_30 <- (5 * soc_0_5 + 10 * soc_5_15 + 15 * soc_15_30) / 30
writeRaster(soc_0_30, "F:/UCI/soil_predictors/soil_organic_carbon/soc_0-30cm_combined.tif", overwrite = TRUE)
soc_0_30_reproj <- project(soc_0_30, ref_raster, method = "bilinear")
soc_0_30_rescaled <- soc_0_30_reproj * 0.1
writeRaster(soc_0_30_rescaled, "F:/UCI/processed_predictors/resampled/soc_resampled.topsoil.tif", overwrite = TRUE)

clay_0_5   <- rast("F:/UCI/soil_predictors/clay/clay_0-5cm_mean.vrt")
clay_5_15  <- rast("F:/UCI/soil_predictors/clay/clay_5-15cm_mean.vrt")
clay_15_30 <- rast("F:/UCI/soil_predictors/clay/clay_15-30cm_mean.vrt")
clay_0_30 <- (5 * clay_0_5 + 10 * clay_5_15 + 15 * clay_15_30) / 30
writeRaster(clay_0_30, "F:/UCI/soil_predictors/clay/clay_0-30cm_combined.tif", overwrite = TRUE)
clay_0_30_reproj <- project(clay_0_30, ref_raster, method = "bilinear")
clay_0_30_rescaled <- clay_0_30_reproj * 0.1
writeRaster(clay_0_30_rescaled, "F:/UCI/processed_predictors/resampled/clay_resampled.topsoil.tif", overwrite = TRUE)

sand_0_5   <- rast("F:/UCI/soil_predictors/sand/sand_0-5cm_mean.vrt")
sand_5_15  <- rast("F:/UCI/soil_predictors/sand/sand_5-15cm_mean.vrt")
sand_15_30 <- rast("F:/UCI/soil_predictors/sand/sand_15-30cm_mean.vrt")
sand_0_30 <- (5 * sand_0_5 + 10 * sand_5_15 + 15 * sand_15_30) / 30
writeRaster(sand_0_30, "F:/UCI/soil_predictors/sand/sand_0-30cm_combined.tif", overwrite = TRUE)
sand_0_30_reproj <- project(sand_0_30, ref_raster, method = "bilinear")
sand_0_30_rescaled <- sand_0_30_reproj * 0.1
writeRaster(sand_0_30_rescaled, "F:/UCI/processed_predictors/resampled/sand_resampled.topsoil.tif", overwrite = TRUE)

silt_0_5   <- rast("F:/UCI/soil_predictors/silt/silt_0-5cm_mean.vrt")
silt_5_15  <- rast("F:/UCI/soil_predictors/silt/silt_5-15cm_mean.vrt")
silt_15_30 <- rast("F:/UCI/soil_predictors/silt/silt_15-30cm_mean.vrt")
silt_0_30 <- (5 * silt_0_5 + 10 * silt_5_15 + 15 * silt_15_30) / 30
writeRaster(silt_0_30, "F:/UCI/soil_predictors/silt/silt_0-30cm_combined.tif", overwrite = TRUE)
silt_0_30_reproj <- project(silt_0_30, ref_raster, method = "bilinear")
silt_0_30_rescaled <- silt_0_30_reproj * 0.1
writeRaster(silt_0_30_rescaled, "F:/UCI/processed_predictors/resampled/silt_resampled.topsoil.tif", overwrite = TRUE)

cfvo_0_5   <- rast("F:/UCI/soil_predictors/coarse_fragments/cfvo_0-5cm_mean.vrt")
cfvo_5_15  <- rast("F:/UCI/soil_predictors/coarse_fragments/cfvo_5-15cm_mean.vrt")
cfvo_15_30 <- rast("F:/UCI/soil_predictors/coarse_fragments/cfvo_15-30cm_mean.vrt")
cfvo_0_30 <- (5 * cfvo_0_5 + 10 * cfvo_5_15 + 15 * cfvo_15_30) / 30
writeRaster(cfvo_0_30, "F:/UCI/soil_predictors/coarse_fragments/cfvo_0-30cm_combined.tif", overwrite = TRUE)
cfvo_0_30_reproj <- project(cfvo_0_30, ref_raster, method = "bilinear")
cfvo_0_30_rescaled <- cfvo_0_30_reproj * 0.1
writeRaster(cfvo_0_30_rescaled, "F:/UCI/processed_predictors/resampled/cfvo_resampled.topsoil.tif", overwrite = TRUE)

nitrogen_0_5   <- rast("F:/UCI/soil_predictors/nitrogen/nitrogen_0-5cm_mean.vrt")
nitrogen_5_15  <- rast("F:/UCI/soil_predictors/nitrogen/nitrogen_5-15cm_mean.vrt")
nitrogen_15_30 <- rast("F:/UCI/soil_predictors/nitrogen/nitrogen_15-30cm_mean.vrt")
nitrogen_0_30 <- (5 * nitrogen_0_5 + 10 * nitrogen_5_15 + 15 * nitrogen_15_30) / 30
writeRaster(nitrogen_0_30, "F:/UCI/soil_predictors/nitrogen/nitrogen_0-30cm_combined.tif", overwrite = TRUE)
nitrogen_0_30_reproj <- project(nitrogen_0_30, ref_raster, method = "bilinear")
nitrogen_0_30_rescaled <- nitrogen_0_30_reproj * 0.1
writeRaster(nitrogen_0_30_rescaled, "F:/UCI/processed_predictors/resampled/nitrogen_resampled.topsoil.tif", overwrite = TRUE)

