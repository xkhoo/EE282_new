#!/bin/bash
#SBATCH --job-name=microtrait
#SBATCH --ntasks=1
#SBATCH --account=ecoevo282_class
#SBATCH --mem=50gb
#SBATCH --cpus-per-task=16
#SBATCH --time=00:30:00
#SBATCH --output=/pub/xkhoo/log/microtrait.example.log
#SBATCH --mail-user=xkhoo@uci.edu
#SBATCH --mail-type=ALL

#Load your environment variables
source ~/.bashrc
conda activate r_env

umask g+rwx

# Run the microtrait.R script using Rscript
Rscript code/scripts/microtrait.R

