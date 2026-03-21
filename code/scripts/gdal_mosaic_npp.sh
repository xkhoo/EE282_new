#!/bin/bash
#SBATCH --job-name=gdal_npp
#SBATCH --output=/pub/xkhoo/log/npp_%A_%a.log
#SBATCH --account=ALLISONS_LAB
#SBATCH --array=0-23
#SBATCH --time=20:00:00
#SBATCH --cpus-per-task=24
#SBATCH --ntasks=1
#SBATCH --mem=50G
#SBATCH --mail-user=xkhoo@uci.edu
#SBATCH --mail-type=BEGIN,FAIL,END
#SBATCH --partition=standard

# Load environment variables
source ~/.bashrc
conda activate gdal

# Permissions to write,read,execute
umask g+rwx


START_YEAR=2001
YEAR=$((START_YEAR + SLURM_ARRAY_TASK_ID))

YEAR_FOLDER="/pub/xkhoo/NPP/NPP_${YEAR}"
TMP_DIR="/pub/xkhoo/NPP/temp/npp_temp_${SLURM_ARRAY_TASK_ID}"
OUT_FILE="/pub/xkhoo/NPP/latest/npp_${YEAR}_cleaned_mosaic.tif"

mkdir -p "$TMP_DIR" logs

echo "Processing MODIS NPP for year $YEAR"


# Process each .tif tile
# Mask NA values of each raster
for tif in "$YEAR_FOLDER"/*.tif; do
  base=$(basename "$tif" .tif)
  echo "Masking & scaling $base..."

  gdal_calc.py -A "$tif" \
    --outfile="$TMP_DIR/${base}_cleaned.tif" \
    --calc="numpy.where((A != 32767) & (A != 32766) & (A != 32765) & (A != 32764) & (A != 32763) & (A != 32762) & (A != 32761), A * 0.0001, -9999)"\
    --NoDataValue=-9999 \
    --type=Float32 \
    --co="COMPRESS=DEFLATE" \
    --overwrite
done


echo "Mosaicking all cleaned tiles for $YEAR..."

gdalwarp "$TMP_DIR"/*_cleaned.tif "$OUT_FILE" \
  -dstnodata -9999 \
  -r bilinear \
  -co "COMPRESS=DEFLATE" \
  -co "BIGTIFF=YES" \
  -t_srs EPSG:4326 \
  --config GDAL_CACHEMAX 200000 -wm 200000 \
  --config GDAL_NUM_THREADS 24 -multi

echo "Mosaic created: $OUT_FILE"
