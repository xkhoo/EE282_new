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

monthly_files <- list.files("/pub/xkhoo/EVI/hdf/EVI_2024/2024_mosaic/",
                            pattern = "EVI_2024_\\d{2}_mosaic.tif$",
                            full.names = TRUE)

# Stack them
evi_stack <- rast(monthly_files)

# Compute the annual mean (ignores NA by default)
evi_annual_mean <- mean(evi_stack, na.rm = TRUE)

NAflag(evi_annual_mean) <- -9999

# Save to disk with NoData properly recorded
writeRaster(
  evi_annual_mean,
  filename = "/pub/xkhoo/EVI/EVI_2024_annual_mean.tif",
  overwrite = TRUE,
  NAflag = -9999,
  gdal = c("COMPRESS=DEFLATE", "BIGTIFF=YES")
)

