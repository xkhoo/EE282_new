#################################
# 00. Load Required Libraries
#################################

library(terra)
library(dplyr)
library(ggplot2)

###################################
# 01. Metadata Preprocessing
###################################

# MAGs from IMG/MER have only genome information; Geographical/ecosystem information can only be found in the metagenome metadata

# Load full MAG-level metadata (including coverage and quality metrics)
# It includes average.Coverage, Bin.Completeness, etc.
rhizo_mag_metadata <- read.csv("data/raw/final_project_raw_csv/img_rhizosphere_10385_mags.csv")
soil_mag_metadata <- read.csv("data/raw/final_project_raw_csv/img_soil_56333_mags.csv")

# Not all MAGs are available for download in the download link provided by JGI (some MAGs are missing)
# From all these downloaded MAGs, only 30522 of them are medium quality
rhizo_downloaded_ids <- read.delim("output/reports/final_project/downloaded_rhizo_mag_ids.txt")
rhizo_mag_metadata_available <- rhizo_mag_metadata %>%
  dplyr::filter(Bin.ID %in% rhizo_downloaded_ids$Bin.ID)

soil_downloaded_ids <- read.delim("output/reports/final_project/downloaded_soil_mag_ids.txt")
soil_mag_metadata_available <- soil_mag_metadata %>%
  dplyr::filter(Bin.ID %in% soil_downloaded_ids$Bin.ID)

# Load genome-level metadata (with lat/lon info)
rhizo_metaG_metadata <- read.csv("data/raw/final_project_raw_csv/img_rhizosphere_509_filtered_genomes.csv")
soil_metaG_metadata <- read.csv("data/raw/final_project_raw_csv/img_soil_3796_updated_genomes.csv")

# Merge MAG-level and genome-level metadata
rhizo_merged <- merge(rhizo_mag_metadata_available, rhizo_metaG_metadata, by = "IMG.Genome.ID", all.x = TRUE)
soil_merged  <- merge(soil_mag_metadata_available, soil_metaG_metadata, by = "IMG.Genome.ID", all.x = TRUE)

# Quality control: Filter medium-quality bacterial MAGs
rhizo_filtered_metadata <- rhizo_merged %>% 
  filter(Bin.Completeness >= 70, Bin.Contamination <= 10) 

# Change the unit of the genome size to Mbp
rhizo_filtered_metadata$Genome_size_Mbp <- rhizo_filtered_metadata$Total.Number.of.Bases / 1e6

# Remove missing lat/lon rows
rhizo_filtered_metadata$Latitude[rhizo_filtered_metadata$Latitude %in% c("", "n/a", "N/A", "NA")] <- NA
rhizo_filtered_metadata$Longitude[rhizo_filtered_metadata$Longitude %in% c("", "n/a", "N/A", "NA")] <- NA
rhizo_filtered_metadata <- rhizo_filtered_metadata %>% filter(!is.na(Latitude) & !is.na(Longitude))

# Add Source to distinguish whether MAG is from soil/plant-associated environments
rhizo_filtered_metadata_source <- rhizo_filtered_metadata %>%
  dplyr::mutate(Source = "plant-associated")
  #dplyr::mutate(Source = "Soil")

# Select only necessary columns and rename the Bin.ID column to MAG_ID
rhizo_clean_metadata <- rhizo_filtered_metadata_source %>%
  dplyr::select(Bin.ID, IMG.Genome.ID, Bin.Completeness, Bin.Contamination, Average.Coverage, Genome_size_Mbp,
                Ecosystem.x, Latitude, Longitude, Source, GTDB.Taxonomy.Lineage) %>%
  rename(MAG_ID = Bin.ID)

# Save clean Metadata
write.csv(rhizo_clean_metadata, "output/reports/final_project/img_mq_rhizo_4963_mags.clean.metadata.csv", row.names = FALSE)

# Repeat the same to soil data
soil_filtered_metadata <- soil_merged %>% 
  filter(Bin.Completeness >= 70, Bin.Contamination <= 10) 

# Change the unit of the genome size to Mbp
soil_filtered_metadata$Genome_size_Mbp <- soil_filtered_metadata$Total.Number.of.Bases / 1e6

# Remove missing lat/lon rows
soil_filtered_metadata$Latitude[soil_filtered_metadata$Latitude %in% c("", "n/a", "N/A", "NA")] <- NA
soil_filtered_metadata$Longitude[soil_filtered_metadata$Longitude %in% c("", "n/a", "N/A", "NA")] <- NA
soil_filtered_metadata <- soil_filtered_metadata %>% filter(!is.na(Latitude) & !is.na(Longitude))

# Add Source to distinguish whether MAG is from soil/plant-associated environments
soil_filtered_metadata_source <- soil_filtered_metadata %>%
  #dplyr::mutate(Source = "plant-associated")
   dplyr::mutate(Source = "Soil")

# Select only necessary columns and rename the Bin.ID column to MAG_ID
soil_clean_metadata <- soil_filtered_metadata_source %>%
  dplyr::select(Bin.ID, IMG.Genome.ID, Bin.Completeness, Bin.Contamination, Average.Coverage, Genome_size_Mbp,
                Ecosystem, Latitude, Longitude, Source, GTDB.Taxonomy.Lineage) %>%
  rename(MAG_ID = Bin.ID)

# Save clean Metadata
write.csv(soil_clean_metadata, "output/reports/final_project/img_mq_soil_26025_mags.clean.metadata.csv", row.names = FALSE)

# Visualize qc summary
qc_summary <- data.frame(
  Source = c(rep("plant-associated", 4), rep("Soil", 4)),
  Step = c("Raw MAGs", "Download available", "After QC", "After lat/lon filter",
           "Raw MAGs", "Download available", "After QC", "After lat/lon filter"),
  Count = c(
    nrow(rhizo_mag_metadata),
    nrow(rhizo_mag_metadata_available),
    nrow(rhizo_merged %>% filter(Bin.Completeness >= 70, Bin.Contamination <= 10)),
    nrow(rhizo_filtered_metadata),
    nrow(soil_mag_metadata),
    nrow(soil_mag_metadata_available),
    nrow(soil_merged %>% filter(Bin.Completeness >= 70, Bin.Contamination <= 10)),
    nrow(soil_filtered_metadata)
  )
)

qc_summary$Step <- factor(
  qc_summary$Step,
  levels = c("Raw MAGs", "Download available", "After QC", "After lat/lon filter"),
  labels = c("Raw\nMAGs", "Download\navailable", "After\nQC", "After lat/lon\nfilter")
)

# rename the plant-associated to rhizosphere
qc_summary$Source <- factor(
  qc_summary$Source,
  levels = c("plant-associated", "Soil"),
  labels = c("Rhizosphere", "Soil")
)

qc_plot <- ggplot(qc_summary, aes(x = Step, y = Count, fill = Source)) +
  geom_col(position = position_dodge(width = 0.9), color = "black") +
  geom_text(
    aes(label = Count),
    position = position_dodge(width = 0.9),
    vjust = -0.25,
    size = 4
  ) +
  theme_bw(base_size = 14) +
  labs(
    title = "Retention of MAGs after metadata processing",
    x = "Processing step",
    y = "Number of MAGs"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.text.x = element_text(size = 13),
    legend.title = element_text(face = "bold")
  )

ggsave("output/figures/final_project/metadata_preprocessing_qc_plot.png", qc_plot, width = 7, height = 5)

##################################
# 02. Relative abundance estimation
##################################
# Run this after running genome dereplication and obtain the cdb and wdb files for cluster information (group similar MAGs to similar cluster)
# Combine the metadata of soil and plant-associated MAGs
combined_metadata <- bind_rows(soil_clean_metadata, rhizo_clean_metadata)

sample_coords <- combined_metadata %>%
  distinct(IMG.Genome.ID, Latitude, Longitude, Source) %>%
  distinct()

#cdb contains species-like cluster information of MAGs
cdb <- read.csv("output/reports/final_project/mag_dereplication/data_tables/Cdb.csv")

#wdb = winner genomes = representative genomes
wdb <- read.csv("output/reports/final_project/mag_dereplication/data_tables/Wdb.csv")

# Cluster-level RA estimation
cluster_ra <- combined_metadata %>%
  left_join(cdb %>% dplyr::select(MAG_ID, secondary_cluster), by = "MAG_ID") %>%
  group_by(IMG.Genome.ID, secondary_cluster) %>%
  summarise(
    ac = sum(Average.Coverage, na.rm = TRUE),
    mags_in_cluster = paste(sort(unique(MAG_ID)), collapse = ";"),
    n_mags = n_distinct(MAG_ID),
    .groups = "drop"
  ) %>%
  group_by(IMG.Genome.ID) %>%
  mutate(RA = ac / sum(ac, na.rm = TRUE)) %>%
  ungroup() %>%
  left_join(
    combined_metadata %>%
      distinct(IMG.Genome.ID, Latitude, Longitude, Source),
    by = "IMG.Genome.ID"
  )

cluster_ra %>%
  group_by(IMG.Genome.ID) %>%
  summarise(n_lat = n_distinct(Latitude), n_lon = n_distinct(Longitude)) %>%
  count(n_lat, n_lon)

# RA estimated using representative genomes only
rep_ids <- wdb %>% distinct(MAG_ID)

rep_ra <- combined_metadata %>%
  semi_join(rep_ids, by = "MAG_ID") %>%
  group_by(IMG.Genome.ID) %>%
  mutate(RA = Average.Coverage / sum(Average.Coverage, na.rm = TRUE)) %>%
  ungroup() %>%
  dplyr::select(-Bin.Completeness,-Bin.Contamination,)

# Each sample should sum to ~1 after renormalization within metaG
rep_ra %>% group_by(IMG.Genome.ID) %>% summarise(sumRA = sum(RA, na.rm=TRUE)) %>% summary()

# Visualize the effect of genome dereplication on the dataset
drep_summary <- data.frame(
  Stage = c("Before dRep", "After dRep"),
  Count = c(
    nrow(combined_metadata),
    nrow(wdb %>% distinct(genome))
  )
)

drep_summary$Stage <- factor(
  drep_summary$Stage,
  levels = c("Before dRep", "After dRep"),
  labels = c("Before dRep", "After dRep")
)

drep_plot <- ggplot(drep_summary, aes(x = Stage, y = Count)) +
  geom_col(fill = "grey70", color = "black") +
  geom_text(aes(label = Count), vjust = -0.25, size = 3) +
  theme_bw(base_size = 14) +
  labs(
    title = "MAG counts before and after dRep",
    x = "Processing step",
    y = "Number of genomes"
  ) +
  theme(
    plot.title = element_text(hjust = 0.5, face = "bold"),
    axis.text.x = element_text(size = 10)
  )

ggsave("output/figures/final_project/drep_reduction_plot.png", drep_plot, width = 7, height = 5)

#######################################################################################
# 03. Extract environmental predictors from processed raster layers (perform locally)
#######################################################################################

# For this project, I prepared two types of predictors_metadata:
# 1. MAGs with cluster info: use `cluster_ra` in the following
# 2. representative MAGs only: repeat and replace `cluster_ra` in the following codes with rep_ra

# -------------------------------------------------------------
# Extract Climate Data (WorldClim)
# -------------------------------------------------------------

# Load WorldClim bioclimatic variables
clim_data <- rast("F:/UCI/processed_predictors/resampled/climate_resampled.tif")

# Extract Climate Variables
points <- vect(cluster_ra[, c("Longitude", "Latitude")], geom = c("Longitude", "Latitude"), crs = "EPSG:4326")
clim_values <- terra::extract(clim_data, points)

# Combine with Metadata
metadata_clim <- cbind(cluster_ra, clim_values[, -1])

# Rename Bioclimatic Variables
metadata_clim <- metadata_clim %>%
  rename(
    MAT = wc2.1_30s_bio_1, MDR = wc2.1_30s_bio_2, ISO = wc2.1_30s_bio_3, TS = wc2.1_30s_bio_4, 
    MaxTwarmM = wc2.1_30s_bio_5, MinTcoldM = wc2.1_30s_bio_6, TAR = wc2.1_30s_bio_7,
    mTwetQ = wc2.1_30s_bio_8, mTdryQ = wc2.1_30s_bio_9, mTwarmQ = wc2.1_30s_bio_10,
    mTcoldQ = wc2.1_30s_bio_11, AP = wc2.1_30s_bio_12, PwetM = wc2.1_30s_bio_13, 
    PdryM = wc2.1_30s_bio_14, PS = wc2.1_30s_bio_15, PwetQ = wc2.1_30s_bio_16,
    PdryQ = wc2.1_30s_bio_17, PwarmQ = wc2.1_30s_bio_18, PcoldQ = wc2.1_30s_bio_19
  )

# Extract evapotranspiration (ET) - from CGIAR-CSI 
ET <- rast("F:/UCI/processed_predictors/resampled/ET_resampled.tif")
metadata_clim$ET <- terra::extract(ET, vect(metadata_clim, geom = c("Longitude", "Latitude"), crs = "EPSG:4326"))[,2]

# Extract aridity index (AI) - from CGIAR-CSI 
AI <- rast("F:/UCI/processed_predictors/resampled/AI_resampled_rescaled.tif")
metadata_clim$AI <- terra::extract(AI, vect(metadata_clim, geom = c("Longitude", "Latitude"), crs = "EPSG:4326"))[,2]

# -------------------------------------------------------------
# Extract Soil Data (SoilGrids)
# -------------------------------------------------------------

# Prepare Points
soil_coords <- vect(metadata_clim, geom = c("Longitude", "Latitude"), crs = "EPSG:4326")

# Extract Soil Variables
extract_soil <- function(raster_path, coords, divide = TRUE) {
  r <- rast(raster_path)
  v <- terra::extract(r, coords)[,2]
  return(v)
}

metadata_clim$soil_pH <- extract_soil("F:/UCI/processed_predictors/resampled/topsoil/pH_resampled.topsoil.tif", soil_coords)
metadata_clim$soil_ocd <- extract_soil("F:/UCI/processed_predictors/resampled/topsoil/ocd_resampled.topsoil.tif", soil_coords)
metadata_clim$soil_cec <- extract_soil("F:/UCI/processed_predictors/resampled/topsoil/cec_resampled.topsoil.tif", soil_coords)
metadata_clim$soil_clay <- extract_soil("F:/UCI/processed_predictors/resampled/topsoil/clay_resampled.topsoil.tif", soil_coords)
metadata_clim$soil_bdod <- extract_soil("F:/UCI/processed_predictors/resampled/topsoil/bdod_resampled.topsoil.tif", soil_coords)
metadata_clim$soil_nitrogen <- extract_soil("F:/UCI/processed_predictors/resampled/topsoil/nitrogen_resampled.topsoil.tif", soil_coords)
metadata_clim$soil_cfvo <- extract_soil("F:/UCI/processed_predictors/resampled/topsoil/cfvo_resampled.topsoil.tif", soil_coords)
metadata_clim$soil_ocs <- extract_soil("F:/UCI/processed_predictors/resampled/topsoil/ocs_resampled.topsoil.tif", soil_coords)
metadata_clim$soil_sand <- extract_soil("F:/UCI/processed_predictors/resampled/topsoil/sand_resampled.topsoil.tif", soil_coords)
metadata_clim$soil_silt <- extract_soil("F:/UCI/processed_predictors/resampled/topsoil/silt_resampled.topsoil.tif", soil_coords)

# Additional soil variables from (http://globalchange.bnu.edu.cn/research/soilwd.jsp)
TC <- rast("F:/UCI/processed_predictors/resampled/topsoil/TC_resampled.topsoil.tif")
metadata_clim$soil_TC <- terra::extract(TC, vect(metadata_clim, geom = c("Longitude", "Latitude"), crs = "EPSG:4326"))[,2]

TN <- rast("F:/UCI/processed_predictors/resampled/topsoil/TN_resampled.topsoil.tif")
metadata_clim$soil_TN <- terra::extract(TN, vect(metadata_clim, geom = c("Longitude", "Latitude"), crs = "EPSG:4326"))[,2]

TP <- rast("F:/UCI/processed_predictors/resampled/topsoil/TP_resampled.topsoil.tif")
metadata_clim$soil_TP <- terra::extract(TP, vect(metadata_clim, geom = c("Longitude", "Latitude"), crs = "EPSG:4326"))[,2]

TK <- rast("F:/UCI/processed_predictors/resampled/topsoil/TK_resampled.topsoil.tif")
metadata_clim$soil_TK <- terra::extract(TK, vect(metadata_clim, geom = c("Longitude", "Latitude"), crs = "EPSG:4326"))[,2]

TS <- rast("F:/UCI/processed_predictors/resampled/topsoil/TS_resampled.topsoil.tif")
metadata_clim$soil_TS <- terra::extract(TS, vect(metadata_clim, geom = c("Longitude", "Latitude"), crs = "EPSG:4326"))[,2]

CACO3 <- rast("F:/UCI/processed_predictors/resampled/topsoil/CACO3_resampled.topsoil.tif")
metadata_clim$soil_CACO3 <- terra::extract(CACO3, vect(metadata_clim, geom = c("Longitude", "Latitude"), crs = "EPSG:4326"))[,2]

BS <- rast("F:/UCI/processed_predictors/resampled/topsoil/BS_resampled.topsoil.tif")
metadata_clim$soil_BS <- terra::extract(BS, vect(metadata_clim, geom = c("Longitude", "Latitude"), crs = "EPSG:4326"))[,2]

# -------------------------------------------------------------
# Extract Topography Data (SRTM)
# -------------------------------------------------------------

elevation_raster <- rast("F:/UCI/processed_predictors/resampled/elevation_resampled.tif")
metadata_clim$elevation <- terra::extract(elevation_raster, vect(metadata_clim, geom = c("Longitude", "Latitude"), crs = "EPSG:4326"))[,2]

# -------------------------------------------------------------
# Extract Vegetation Data (MODIS-products)
# -------------------------------------------------------------

# long-term average NPP
npp_mean <- rast("F:/UCI/production_predictors/NPP/NPP_mean_2001_2024.tif")
metadata_clim$npp_mean <- terra::extract(npp_mean, vect(metadata_clim, geom = c("Longitude", "Latitude"), crs = "EPSG:4326"))[,2]

# long-term average EVI
evi_mean <- rast("F:/UCI/production_predictors/EVI/EVI_longterm_mean_2001_2024.tif")
metadata_clim$evi_mean <- terra::extract(evi_mean, vect(metadata_clim, geom = c("Longitude", "Latitude"), crs = "EPSG:4326"))[,2]

# land cover/biome classification (1-18 types)
lc_mode <- rast("F:/UCI/production_predictors/Landcover/longterm_land_masked.tif")
metadata_clim$land_cover <- terra::extract(lc_mode, vect(metadata_clim, geom = c("Longitude", "Latitude"), crs = "EPSG:4326"))[,2]

# land cover label
lc <- tibble::tibble(
  land_cover = 1:18,
  land_cover_class = c(
    "Evergreen_Needleleaf",
    "Evergreen_Broadleaf",
    "Deciduous_Needleleaf",
    "Deciduous_Broadleaf",
    "Mixed_Forest",
    "Closed_Shrublands",
    "Open_Shrublands",
    "Woody_Savannas",
    "Savannas",
    "Grasslands",
    "Permanent_Wetlands",
    "Croplands",
    "Urban_and_Built-up",
    "Cropland_Mosaics",
    "Snow_and_Ice",
    "Bare_Soil_and_Rocks",
    "Water_Bodies",
    "Tundra"
  )
)

metadata_clim_class <- metadata_clim %>%
  mutate(land_cover = as.integer(land_cover)) %>%
  left_join(lc, by = "land_cover") %>%
  mutate(
    land_cover_class = factor(land_cover_class, levels = lc$land_cover_class) #make it an ordered factor
  )

# -------------------------------------------------------------
# Save Final Output
# -------------------------------------------------------------
write.csv(metadata_clim_class, "F:/UCI/metadata/IMGM_mb/imgmq_30517_mags_cluster_ra_env.csv", row.names = F)

# The final `MAGs with cluster info` output was uploaded as `output/reports/final_project/imgmq_30517_mags_cluster_ra_env.csv`
# The final `Representative MAGs only` output was uploaded as `output/reports/final_project/imgmq_15653_mags_rep_ra_env`
