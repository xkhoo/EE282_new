##Use conda-safe user library path 
userlib <- file.path(Sys.getenv("HOME"), "R", paste0("x86_64-conda-linux-gnu-library"), paste(R.version$major, R.version$minor, sep = "."))
if (!dir.exists(userlib)) dir.create(userlib, recursive = TRUE)
.libPaths(c(userlib, .libPaths()))


# Install required packages
#install.packages("kmed", repos = "https://cloud.r-project.org")
#install.packages("pheatmap", repos = "https://cloud.r-project.org")
#install.packages("devtools")
#install.packages("gtools", repos = "https://cloud.r-project.org")
library(devtools)
#list_of_packages = c("R.utils", "RColorBrewer", "ape", "assertthat", "checkmate", "coRdon", "corrplot", "doParallel", "dplyr", "futile.logger", "grid", "gtools", "kmed", "lazyeval", "tictoc", "tidyr")
#newpackages <- list_of_packages[!(list_of_packages %in% installed.packages()[,"Package"])]
#if(length(newpackages)) install.packages(newpackages)
#if (!requireNamespace("BiocManager", quietly = TRUE))
#install.packages("BiocManager")
#library(BiocManager)
#BiocManager::install("Biostrings")
#BiocManager::install("coRdon")
#BiocManager::install("ComplexHeatmap")
#install.packages("seqinr")
#install.packages("vegan")
# Install dependencies (gRODON, Hmmer)
#devtools::install_github("jlw-ecoevo/gRodon")
library(seqinr)
# Install microtrait (require seqinr)
#devtools::install_github("ukaraoz/microtrait")
library(vegan)
library(gRodon)
library(coRdon)
library(Biostrings)
library(futile.logger)
library(kmed)
library(tictoc)
library(assertthat)
library(doParallel)
library(dplyr)
library(grid)
library(gtools)
library(dplyr)
library(microtrait)

# run hmm database to prepare the model (run this only for one time): document= https://github.com/ukaraoz/microtrait
microtrait::prep.hmmmodels()

# Annotating traits from genome sequences
# Working with multiple genomes (parallel workflow)

####################################
# A. Examples for the final project
####################################

#example_genomes_dir = "data/raw/final_project_example_genomes"
#example_output_dir = "data/processed/final_project_example_microtrait_rds"
#dir.create(example_output_dir, recursive = TRUE, showWarnings = FALSE)

# Load the example genomes
#example_genomes_files = list.files(example_genomes_dir, full.names = TRUE, recursive = TRUE, pattern = ".fna$")

#message("Number of cores:", parallel::detectCores(), "\n")
#tictoc::tic.clearlog()
#tictoc::tic(paste0("Running microtrait for ", length(example_genomes_files)))
#ncores <- floor(parallel::detectCores() * 0.7)

# Run microtrait annotation and save the output rds files to the processed directory
#example_outdirs <- rep(example_output_dir, length(example_genomes_files))
#microtrait_results = extract.traits.parallel(example_genomes_files, example_outdirs, ncores = ncores)
#tictoc::toc(log = "TRUE")

rds_dir <- "data/processed/final_project_example_microtrait_rds" 
rds_files <- list.files(rds_dir, pattern = "\\.microtrait\\.rds$", full.names = TRUE)
#rds_files = unlist(parallel::mclapply(microtrait_results, "[[", "rds_file", mc.cores = ncores))
# Generate sample ID from the genome file name
ids <- sub("\\.microtrait\\.rds$", "", basename(rds_files))
# Read the results for each genome (use only 1 core)

# Read the results for each genome
genomeset_results <- make.genomeset.results(
 rds_files = rds_files,
 ids = ids,
 ncores = 1
)

# Check the dimension of the results
lapply(genomeset_results, dim)

# There should be 5 different matrices within the output
names(genomeset_results) 

# Trait matrix granularity 3 (microtrait has different trait resolutions: 1 = coarse, 2 = intermediate, 3 = fine. For my final project, I am extracting only 3)
# Rename the id column to either genome_ID or MAG_ID. For this example, I am using genome_ID because these genomes are not MAGs.
trait_matrixatgranularity3 <- data.frame(
  genomeset_results$trait_matrixatgranularity3) %>%
  rename(genome_ID = id)
names(trait_matrixatgranularity3)
write.csv(trait_matrixatgranularity3, file = "output/reports/final_project/example_traitgranularity3.csv", row.names = FALSE)

##########################################
# B. The actual steps for my final project
##########################################

# For large datasets (eg: 30000+ genomes, make batches to run because the trait annotation steps are memory heavy) 
#genomes_dir = "/pub/xkhoo/MAGS/microtrait_batches/batch_0004"
#output_dir = "/pub/xkhoo/microtrait/soil_microtrait_rds"

#genomes_files = list.files(genomes_dir, full.names = T, recursive = T, pattern = ".fna$")

# To determine number of "cores" on machine (log this for sanity check in job running)
#message("Number of cores:", parallel::detectCores(), "\n")
# To use 70% of the available cores
#tictoc::tic.clearlog()
#tictoc::tic(paste0("Running microtrait for ", length(genomes_files)))
#ncores <- floor(parallel::detectCores() * 0.7)
#microtrait_results = extract.traits.parallel(genomes_files, output_dir, ncores = ncores)
#tictoc::toc(log = "TRUE")

# The trait matrix generation for my project was run locally on Ubuntu after processing all batches (for both rhizosphere and soil MAGS)
# The rds files were transfered from the hpc to my hard drive
#rds_dir <- "../../microtrait/soil_microtrait_rds/"
#rds_files <- list.files(rds_dir, pattern = "\\.microtrait\\.rds$", full.names = TRUE)
#ids <- sub("\\.microtrait\\.rds$", "", basename(rds_files))
# Read the results for each genome
#ncores=1
#genomeset_results <- make.genomeset.results(
 # rds_files = rds_files,
  #ids = ids,
  #ncores = ncores
#)

# Check the dimension of the results
#lapply(genomeset_results, dim)

# There should be 5 different matrices within the output
#names(genomeset_results)

# Trait matrix granularity 3 (microtrait has different trait resolutions: 1 = coarse, 2 = intermediate, 3 = fine. For my final project, I am extracting only 3)
# Rename the id column to either genome_ID or MAG_ID.
#trait_matrixatgranularity3 <- data.frame(
 # genomeset_results$trait_matrixatgranularity3) %>%
  #rename(MAG_ID = id)
#names(trait_matrixatgranularity3)
#write.csv(trait_matrixatgranularity3, file = "/pub/xkhoo/microtrait/mb_soil_microtrait/soil_traitgranularity3.csv", row.names = FALSE)

# In total, I generated 3 traitgranularity.csv files: soil, rhizosphere, additional (missing genomes from the first JGI download links)
