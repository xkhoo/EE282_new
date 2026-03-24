#########################################
# 00. Libraries
#########################################

library(dplyr)
library(tidyr)
library(ggplot2)
library(readr)
library(purrr)
library(tibble)
library(vegan)
library(RColorBrewer)

#########################################
# 01. Working directory and paths
#########################################

metadata_rep_path      <- "output/reports/final_project/imgmq_15653_mags_rep_ra_env.csv"
metadata_cluster_path  <- "output/reports/final_project/imgmq_30517_mags_cluster_ra_env.csv"
# This table summarizes the trait types (count, binary, continuous) of microtrait output
trait_map_path         <- "data/processed/microtrait_mapping_draft4.csv"
soil_g3_path           <- "output/reports/final_project/soil_traitgranularity3.csv"
rhizo_g3_path          <- "output/reports/final_project/rhizo_traitgranularity3.csv"
additional_g3_path     <- "output/reports/final_project/additional_traitgranularity3.csv"
cdb_path               <- "output/reports/final_project/mag_dereplication/data_tables/Cdb.csv"

dir.create("output/reports/final_project/pca_matrices", showWarnings = FALSE)
dir.create("output/tables/final_project", showWarnings = FALSE)
#########################################
# 02. Parameters
#########################################

excluded_land_cover <- c("11", "13", "15", "17")  # non-soil land cover
pcs_to_keep         <- paste0("PC", 1:6)
pcs_to_report       <- 5
top_n_pca           <- 15
n_show_pcs          <- 20

plot_width_standard <- 8
plot_height_standard <- 6
plot_width_wide <- 10
plot_height_wide <- 7
plot_dpi <- 300

#########################################
# 03. Helper functions
#########################################

pca_var_df <- function(pca_obj, label) {
  ve <- (pca_obj$sdev^2) / sum(pca_obj$sdev^2)
  tibble(
    PC = seq_along(ve),
    var_explained = ve,
    var_explained_pct = 100 * ve,
    cum_var_pct = 100 * cumsum(ve),
    version = label
  )
}

make_signatures <- function(load_df, pcs = 1:5, top_n = 15) {
  bind_rows(lapply(pcs, function(k) {
    pc <- paste0("PC", k)
    tmp <- load_df %>% select(trait, all_of(pc))
    
    bind_rows(
      tmp %>%
        arrange(desc(.data[[pc]])) %>%
        slice_head(n = top_n) %>%
        mutate(PC = pc, direction = "positive"),
      tmp %>%
        arrange(.data[[pc]]) %>%
        slice_head(n = top_n) %>%
        mutate(PC = pc, direction = "negative")
    )
  }))
}

save_plot <- function(plot_obj, filename,
                      width = plot_width_standard,
                      height = plot_height_standard,
                      dpi = plot_dpi) {
  ggsave(
    filename = filename,
    plot = plot_obj,
    width = width,
    height = height,
    dpi = dpi
  )
}

#########################################
# 04. Load and standardize metadata
#########################################

metadata_rep <- read.csv(metadata_rep_path) %>%
  mutate(
    MAG_ID = as.character(MAG_ID),
    IMG.Genome.ID = as.character(IMG.Genome.ID)
  )

metadata_cluster <- read.csv(metadata_cluster_path) %>%
  mutate(
    IMG.Genome.ID = as.character(IMG.Genome.ID),
    secondary_cluster = as.character(secondary_cluster)
  )

metadata_rep_filtered <- metadata_rep %>%
  filter(!land_cover %in% excluded_land_cover)

metadata_cluster_filtered <- metadata_cluster %>%
  filter(!land_cover %in% excluded_land_cover)

sample_landcover <- metadata_cluster_filtered %>%
  distinct(IMG.Genome.ID, land_cover_class)

#########################################
# 05. Load trait map and define count-like traits
#########################################

data_type_map <- read.csv(trait_map_path)

trait_map_countlike <- data_type_map %>%
  filter(Data_type %in% c("count", "count_by_substrate")) %>%
  distinct(Microtrait_trait, Trait_group, Data_type)

countlike_traits <- trait_map_countlike$Microtrait_trait

#########################################
# 06. Load MicroTrait granularity-3 matrices
#########################################

soil_g3 <- read.csv(soil_g3_path) %>%
  mutate(MAG_ID = as.character(MAG_ID))

rhizo_g3 <- read.csv(rhizo_g3_path) %>%
  mutate(MAG_ID = as.character(MAG_ID))

additional_g3 <- read.csv(additional_g3_path) %>%
  mutate(MAG_ID = as.character(MAG_ID))

combined_microtrait_g3 <- bind_rows(soil_g3, rhizo_g3, additional_g3)

#########################################
# 07. Subset representative genomes and join cluster info
#########################################

g3_rep <- combined_microtrait_g3 %>%
  semi_join(metadata_rep_filtered %>% distinct(MAG_ID), by = "MAG_ID")

cdb <- read.csv(cdb_path) %>%
  mutate(
    MAG_ID = as.character(MAG_ID),
    secondary_cluster = as.character(secondary_cluster)
  ) %>%
  select(MAG_ID, secondary_cluster) %>%
  distinct()

g3_rep_cluster <- g3_rep %>%
  left_join(cdb, by = "MAG_ID")

#########################################
# 08. Identify usable count-like traits
#########################################

countlike_traits_in_g3 <- intersect(countlike_traits, colnames(g3_rep_cluster))

all_zero_traits <- g3_rep_cluster %>%
  summarise(
    across(
      all_of(countlike_traits_in_g3),
      ~ all(is.na(.x) | .x == 0)
    )
  ) %>%
  pivot_longer(
    everything(),
    names_to = "trait",
    values_to = "all_zero"
  ) %>%
  filter(all_zero) %>%
  pull(trait)

countlike_traits_in_g3 <- setdiff(countlike_traits_in_g3, all_zero_traits)

#########################################
# 09. Check genome size association for a subset of traits
#########################################

check_traits <- head(countlike_traits_in_g3, 10)

df_check <- g3_rep_cluster %>%
  mutate(genome_mbp = genome_length / 1e6) %>%
  select(genome_mbp, all_of(check_traits)) %>%
  pivot_longer(-genome_mbp, names_to = "trait", values_to = "val") %>%
  group_by(trait) %>%
  summarise(
    rho = cor(genome_mbp, val, method = "spearman", use = "complete.obs"),
    median = median(val, na.rm = TRUE),
    max = max(val, na.rm = TRUE),
    .groups = "drop"
  ) %>%
  arrange(desc(abs(rho)))

write.csv(df_check, "output/tables/final_project/trait_genome_size_check.csv", row.names = FALSE)

#########################################
# 10. Residualize count-like traits by genome size
#########################################

g3_rep_cluster <- g3_rep_cluster %>%
  mutate(
    genome_mbp = genome_length / 1e6,
    log_genome = log(genome_mbp)
  )

resid_list <- lapply(countlike_traits_in_g3, function(tr) {
  df <- g3_rep_cluster %>%
    select(MAG_ID, secondary_cluster, log_genome, !!sym(tr)) %>%
    rename(val = !!sym(tr)) %>%
    mutate(y = log1p(val))
  
  fit <- lm(y ~ log_genome, data = df)
  
  df %>%
    mutate(resid = resid(fit)) %>%
    select(MAG_ID, secondary_cluster, resid) %>%
    rename(!!tr := resid)
})

g3_countlike_resid <- reduce(
  resid_list,
  left_join,
  by = c("MAG_ID", "secondary_cluster")
)

#########################################
# 11. Compute community-weighted mean (CWM) matrices
#########################################

cwm_countlike_resid <- metadata_cluster_filtered %>%
  select(IMG.Genome.ID, secondary_cluster, RA) %>%
  left_join(g3_countlike_resid, by = "secondary_cluster") %>%
  group_by(IMG.Genome.ID) %>%
  summarise(
    across(all_of(countlike_traits_in_g3), ~ sum(RA * .x, na.rm = TRUE)),
    .groups = "drop"
  )

cwm_countlike_raw <- metadata_cluster_filtered %>%
  select(IMG.Genome.ID, secondary_cluster, RA) %>%
  left_join(
    g3_rep_cluster %>% select(secondary_cluster, all_of(countlike_traits_in_g3)),
    by = "secondary_cluster"
  ) %>%
  group_by(IMG.Genome.ID) %>%
  summarise(
    across(all_of(countlike_traits_in_g3), ~ sum(RA * .x, na.rm = TRUE)),
    .groups = "drop"
  )

#########################################
# 12. Transform matrices for PCA and NMF
#########################################

cwm_pca_resid_mat <- cwm_countlike_resid %>%
  mutate(across(all_of(countlike_traits_in_g3), ~ as.numeric(scale(.x))))

cwm_pca_raw_mat <- cwm_countlike_raw %>%
  mutate(across(all_of(countlike_traits_in_g3), log1p)) %>%
  mutate(across(all_of(countlike_traits_in_g3), ~ as.numeric(scale(.x))))

X_pca_resid <- cwm_pca_resid_mat %>% select(-IMG.Genome.ID)
X_pca_raw   <- cwm_pca_raw_mat %>% select(-IMG.Genome.ID)

stopifnot(all(is.finite(as.matrix(X_pca_resid))))
stopifnot(all(is.finite(as.matrix(X_pca_raw))))


#########################################
# 13. Run PCA
#########################################

pca_resid <- prcomp(as.matrix(X_pca_resid), center = FALSE, scale. = FALSE)
pca_raw   <- prcomp(as.matrix(X_pca_raw), center = FALSE, scale. = FALSE)

#########################################
# 14. PCA variance explained
#########################################

var_resid <- pca_var_df(pca_resid, "residual")
var_raw   <- pca_var_df(pca_raw, "raw")
var_all   <- bind_rows(var_raw, var_resid)

write.csv(var_resid, "output/tables/final_project/pca_variance_resid.csv", row.names = FALSE)
write.csv(var_raw,   "output/tables/final_project/pca_variance_raw.csv", row.names = FALSE)

var_all_plot <- var_all %>%
  filter(PC <= n_show_pcs)

plot_pca_scree <- ggplot(var_all, aes(x = PC, y = var_explained, color = version)) +
  geom_line() +
  geom_point() +
  theme_bw(base_size = 16) +
  labs(
    title = "PCA scree plot",
    x = "Principal Component",
    y = "Variance explained",
    color = "Version"
  )

plot_pca_variance_barline <- ggplot(var_all_plot, aes(x = PC)) +
  geom_col(
    aes(y = var_explained_pct, fill = version),
    position = position_dodge(width = 0.9),
    width = 0.8
  ) +
  geom_line(
    aes(y = cum_var_pct, color = version, group = version),
    linewidth = 1
  ) +
  geom_point(aes(y = cum_var_pct, color = version), size = 2) +
  theme_bw(base_size = 16) +
  scale_x_continuous(breaks = seq(1, n_show_pcs, by = 2)) +
  labs(
    title = paste0(
      "PCA variance explained and cumulative variance (first ",
      n_show_pcs,
      " PCs)"
    ),
    x = "Principal Component",
    y = "Percent (%)",
    fill = "Version",
    color = "Version"
  )

#print(plot_pca_scree)
#print(plot_pca_variance_barline)

save_plot(plot_pca_scree, "output/figures/final_project/pca_scree_plot.png")
save_plot(
  plot_pca_variance_barline,
  "output/figures/final_project/pca_variance_barline.png",
  width = plot_width_wide,
  height = plot_height_wide
)

#########################################
# 15. PCA scores and PCA score plots
#########################################

scores_resid <- as.data.frame(pca_resid$x) %>%
  mutate(IMG.Genome.ID = cwm_pca_resid_mat$IMG.Genome.ID) %>%
  relocate(IMG.Genome.ID)

scores_raw <- as.data.frame(pca_raw$x) %>%
  mutate(IMG.Genome.ID = cwm_pca_raw_mat$IMG.Genome.ID) %>%
  relocate(IMG.Genome.ID)

write.csv(scores_resid, "output/tables/final_project/pca_scores_resid.csv", row.names = FALSE)
write.csv(scores_raw,   "output/tables/final_project/pca_scores_raw.csv", row.names = FALSE)

scores_resid_plot <- scores_resid %>%
  select(IMG.Genome.ID, PC1, PC2) %>%
  left_join(sample_landcover, by = "IMG.Genome.ID")

scores_raw_plot <- scores_raw %>%
  select(IMG.Genome.ID, PC1, PC2) %>%
  left_join(sample_landcover, by = "IMG.Genome.ID")

pve_resid <- (pca_resid$sdev^2) / sum(pca_resid$sdev^2)
pve_raw   <- (pca_raw$sdev^2) / sum(pca_raw$sdev^2)

plot_pca_resid_pc1_pc2 <- ggplot(scores_resid_plot, aes(x = PC1, y = PC2)) +
  geom_point(alpha = 0.6) +
  theme_bw(base_size = 16) +
  labs(
    title = "Residual PCA strategy space",
    x = paste0("PC1 (", round(100 * pve_resid[1], 1), "% variance)"),
    y = paste0("PC2 (", round(100 * pve_resid[2], 1), "% variance)")
  )

plot_pca_raw_pc1_pc2 <- ggplot(scores_raw_plot, aes(x = PC1, y = PC2)) +
  geom_point(alpha = 0.6) +
  theme_bw(base_size = 16) +
  labs(
    title = "Raw PCA strategy space",
    x = paste0("PC1 (", round(100 * pve_raw[1], 1), "% variance)"),
    y = paste0("PC2 (", round(100 * pve_raw[2], 1), "% variance)")
  )

plot_pca_resid_pc1_pc2_landcover <- ggplot(
  scores_resid_plot,
  aes(x = PC1, y = PC2, color = land_cover_class)
) +
  geom_point(alpha = 0.7, size = 2) +
  theme_bw(base_size = 16) +
  labs(
    title = "Residual PCA strategy space by land cover",
    x = paste0("PC1 (", round(100 * pve_resid[1], 1), "% variance)"),
    y = paste0("PC2 (", round(100 * pve_resid[2], 1), "% variance)"),
    color = "Land cover class"
  )

plot_pca_raw_pc1_pc2_landcover <- ggplot(
  scores_raw_plot,
  aes(x = PC1, y = PC2, color = land_cover_class)
) +
  geom_point(alpha = 0.7, size = 2) +
  theme_bw(base_size = 16) +
  labs(
    title = "Raw PCA strategy space by land cover",
    x = paste0("PC1 (", round(100 * pve_raw[1], 1), "% variance)"),
    y = paste0("PC2 (", round(100 * pve_raw[2], 1), "% variance)"),
    color = "Land cover class"
  )

#print(plot_pca_resid_pc1_pc2)
#print(plot_pca_raw_pc1_pc2)
#print(plot_pca_resid_pc1_pc2_landcover)
#print(plot_pca_raw_pc1_pc2_landcover)

save_plot(plot_pca_resid_pc1_pc2, "output/figures/final_project/pca_resid_pc1_pc2.png")
save_plot(plot_pca_raw_pc1_pc2, "output/figures/final_project/pca_raw_pc1_pc2.png")
save_plot(
  plot_pca_resid_pc1_pc2_landcover,
  "output/figures/final_project/pca_resid_pc1_pc2_landcover.png",
  width = plot_width_wide,
  height = plot_height_wide
)
save_plot(
  plot_pca_raw_pc1_pc2_landcover,
  "output/figures/final_project/pca_raw_pc1_pc2_landcover.png",
  width = plot_width_wide,
  height = plot_height_wide
)

#########################################
# 17. PCA loadings and signatures
#########################################

load_resid <- as.data.frame(pca_resid$rotation) %>%
  rownames_to_column("trait")

load_raw <- as.data.frame(pca_raw$rotation) %>%
  rownames_to_column("trait")

write.csv(load_resid, "output/tables/final_project/pca_loadings_resid.csv", row.names = FALSE)
write.csv(load_raw,   "output/tables/final_project/pca_loadings_raw.csv", row.names = FALSE)

sig_resid <- make_signatures(load_resid, pcs = 1:pcs_to_report, top_n = top_n_pca)
sig_raw   <- make_signatures(load_raw,   pcs = 1:pcs_to_report, top_n = top_n_pca)

write.csv(sig_resid, "output/tables/final_project/pca_signatures_resid.csv", row.names = FALSE)
write.csv(sig_raw,   "output/tables/final_project/pca_signatures_raw.csv", row.names = FALSE)

#########################################
# 18. Correlation of PC1 with community mean genome size
#########################################

cwm_genome_size <- metadata_cluster_filtered %>%
  select(IMG.Genome.ID, secondary_cluster, RA) %>%
  left_join(
    g3_rep_cluster %>% select(secondary_cluster, genome_mbp),
    by = "secondary_cluster"
  ) %>%
  group_by(IMG.Genome.ID) %>%
  summarise(
    mean_genome_mbp = sum(RA * genome_mbp, na.rm = TRUE),
    .groups = "drop"
  )

pc1_genome_tbl <- scores_raw %>%
  select(IMG.Genome.ID, PC1_raw = PC1) %>%
  left_join(scores_resid %>% select(IMG.Genome.ID, PC1_resid = PC1), by = "IMG.Genome.ID") %>%
  left_join(cwm_genome_size, by = "IMG.Genome.ID")

rho_raw_pc1 <- cor(
  pc1_genome_tbl$PC1_raw,
  log(pc1_genome_tbl$mean_genome_mbp),
  method = "spearman",
  use = "complete.obs"
)

rho_resid_pc1 <- cor(
  pc1_genome_tbl$PC1_resid,
  log(pc1_genome_tbl$mean_genome_mbp),
  method = "spearman",
  use = "complete.obs"
)

pc1_genome_cor <- tibble(
  version = c("raw", "residual"),
  spearman_rho = c(rho_raw_pc1, rho_resid_pc1)
)

write.csv(pc1_genome_cor, "output/tables/final_project/pc1_genome_size_correlation.csv", row.names = FALSE)

#########################################
# 19. Prepare PCA score matrices for downstream modeling
#########################################

meta_pca <- metadata_cluster_filtered %>%
  distinct(IMG.Genome.ID, .keep_all = TRUE) %>%
  select(
    -secondary_cluster, -ac, -RA, -mags_in_cluster, -n_mags,
    -Source, -land_cover_class, -Latitude, -Longitude,
    -(soil_TC:soil_BS)
  ) %>%
  mutate(across(any_of("land_cover"), as.factor))

raw_pc_dfs <- setNames(vector("list", length(pcs_to_keep)), pcs_to_keep)
resid_pc_dfs <- setNames(vector("list", length(pcs_to_keep)), pcs_to_keep)

for (pc in pcs_to_keep) {
  raw_pc_dfs[[pc]] <- scores_raw %>%
    select(IMG.Genome.ID, all_of(pc)) %>%
    left_join(meta_pca, by = "IMG.Genome.ID")
  
  resid_pc_dfs[[pc]] <- scores_resid %>%
    select(IMG.Genome.ID, all_of(pc)) %>%
    left_join(meta_pca, by = "IMG.Genome.ID")
}

for (pc in pcs_to_keep) {
  write.csv(
    raw_pc_dfs[[pc]],
    file.path("output/reports/final_project/pca_matrices", paste0("RAW_", pc, "_matrix.csv")),
    row.names = FALSE
  )
  
  write.csv(
    resid_pc_dfs[[pc]],
    file.path("output/reports/final_project/pca_matrices", paste0("RESID_", pc, "_matrix.csv")),
    row.names = FALSE
  )
}

