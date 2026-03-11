#!/usr/bin/bash
#SBATCH --job-name=busco
#SBATCH --output=/pub/xkhoo/log/busco_hw4_new.log
#SBATCH --ntasks=1
#SBATCH --account=ALLISONS_LAB
#SBATCH --mem=50gb
#SBATCH --cpus-per-task=16
#SBATCH --time=01:00:00
#SBATCH --mail-user=xkhoo@uci.edu
#SBATCH --mail-type=BEGIN,FAIL,END

# Activate the environment
source ~/.bashrc
conda activate busco
umask g+rwx

OUTDIR="output/reports/homework4/assembly/busco"
mkdir -p "$OUTDIR"
ISO1="output/reports/homework4/assembly/iso1.dm.asm.bp.p_ctg.fa"
FSCAFF="data/raw/dmel_all_chromosomes.fasta.gz"

# 2C. Calculate BUSCO scores
# Iso1 assembly
busco -i "$ISO1" \
   -m genome \
   -l drosophila_odb12 \
   -c 16 \
   -o iso1_busco \
   --out_path "$OUTDIR"

# FlyBase scaffold
zcat "$FSCAFF" > "data/processed/dmel_all_chromosomes.fa"
busco -i "data/processed/dmel_all_chromosomes.fa" \
   -m genome \
   -l drosophila_odb12 \
   -c 16 \
   -o flybase_scaff_busco \
   --out_path "$OUTDIR"
