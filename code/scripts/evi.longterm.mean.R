##Use conda-safe user library path
userlib <- file.path(Sys.getenv("HOME"), "R", paste0("x86_64-conda-linux-gnu-library"), paste(R.version$major, R.version$minor, sep = "."))
if (!dir.exists(userlib)) dir.create(userlib, recursive = TRUE)
.libPaths(c(userlib, .libPaths()))

library(geodata)
library(terra)
library(dplyr)
library(caret)
library(readr)

terraOptions(threads = 16)

# List all annual mean EVI files
annual_files <- list.files("/pub/xkhoo/EVI/annual_mean/",
                           pattern = "EVI_20\\d{2}_annual_mean\\.tif$",
                           full.names = TRUE)

# Stack the annual mean rasters
annual_stack <- rast(annual_files)

# Calculate long-term average (e.g., 2001–2024)
evi_longterm_mean <- mean(annual_stack, na.rm = TRUE)

NAflag(evi_longterm_mean) <- -9999

writeRaster(
  evi_longterm_mean,
  filename = "/pub/xkhoo/EVI/EVI_longterm_mean_2001_2024.tif",
  overwrite = TRUE,
  NAflag = -9999,
  gdal = c("COMPRESS=DEFLATE", "TILED=YES", "BIGTIFF=YES")
)
