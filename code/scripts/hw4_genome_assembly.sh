#!/usr/bin/bash
#SBATCH --job-name=Genome_Assembly
#SBATCH --output=/pub/xkhoo/log/genome_assembly.log
#SBATCH --ntasks=1
#SBATCH --account=ALLISONS_LAB
#SBATCH --mem=50gb
#SBATCH --cpus-per-task=16
#SBATCH --time=01:00:00
#SBATCH --mail-user=xkhoo@uci.edu
#SBATCH --mail-type=BEGIN,FAIL,END


# Activate the environment
source ~/.bashrc
conda activate ee282
umask g+rwx

# Obtain the reads from JJ's folder
DATADIR="data/raw"
cp /pub/jje/ee282/ISO_HiFi_Shukla2025.fasta.gz "${DATADIR}"

READS="${DATADIR}/ISO_HiFi_Shukla2025.fasta.gz"
OUTDIR="result/homework4/assembly"
mkdir -p "${OUTDIR}"

# PART I: Assemble a genome using Pacbio HIFI reads (job submission using sbatch here)
# Run the hifiasm for genome assembly
hifiasm -t 16 -o "${OUTDIR}/iso1.dm.asm" "${READS}"

