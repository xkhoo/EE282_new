#!/bin/bash
#SBATCH --job-name=dRep
#SBATCH --output=/pub/xkhoo/log/dRep.log
#SBATCH --account=ALLISONS_LAB
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=8
#SBATCH --mem-per-cpu=15G
#SBATCH --time=128:00:00
#SBATCH --mail-user=xkhoo@uci.edu
#SBATCH --mail-type=BEGIN,END,FAIL
#SBATCH --partition=standard

# Load environment variables
source ~/.bashrc
conda activate phylo

# Permissions to write,read,execute
umask g+rwx

DIR="/pub/xkhoo/MAGS/MQ_merged_JGI"
OUTDIR="/pub/xkhoo/phylo/dereplication/merged_JGI"
GENOMEINFO="/pub/xkhoo/phylo/dereplication/MQ_30522_mags_genome_info_filtered.csv"

THREADS="${SLURM_CPUS_PER_TASK:-8}"
echo "THREADS=$THREADS"

# Define number of threads; otherwise use the default
#if [[ -n "${SLURM_CPUS_PER_TASK:-}" ]]; then
#  THREADS="$SLURM_CPUS_PER_TASK"
#else
 # THREADS=16
#fi

bash /pub/xkhoo/phylo/dereplication/derep_genome_info.sh "$DIR" "$OUTDIR" "$GENOMEINFO" "$THREADS"
