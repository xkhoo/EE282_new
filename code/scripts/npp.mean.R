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
# List of NPP rasters
npp_files <- list.files("/pub/xkhoo/NPP/mosaic_latest/", pattern = ".tif$", full.names = TRUE)

# Stack them
npp_stack <- rast(npp_files)

# Calculate mean across time (per-pixel average)
npp_multi_year_mean <- mean(npp_stack, na.rm = TRUE)

# Set the NoData value explicitly
NAflag(npp_multi_year_mean) <- -9999

# Save to disk with NoData properly recorded
writeRaster(
  npp_multi_year_mean,
  filename = "/pub/xkhoo/NPP/mosaic/NPP_mean_2001_2024.tif",
  overwrite = TRUE,
  NAflag = -9999,
  gdal = c("COMPRESS=DEFLATE", "BIGTIFF=YES")
)
