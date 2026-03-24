#!/bin/bash
#SBATCH --job-name=evi_annual_mean
#SBATCH --output=/pub/xkhoo/log/evi.annual.mean.log
#SBATCH --ntasks=1                   # Run a single task
#SBATCH --account=ALLISONS_LAB
#SBATCH --mem=100gb                     # Job memory request
#SBATCH --cpus-per-task=16            # Number of CPU cores per task
#SBATCH --time=00:10:00              # Time limit hrs:min:sec
#SBATCH --mail-user=xkhoo@uci.edu
#SBATCH --mail-type=BEGIN,FAIL,END


#Load your environment variables
source ~/.bashrc
conda activate r_env

# Give yourself permissions to read, write, and execute
umask g+rwx

# Run the microtrait.R script using Rscript
Rscript evi.annual.mean.R

