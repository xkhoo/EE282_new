#!/usr/bin/bash
#SBATCH --job-name=EC
#SBATCH --output=/pub/xkhoo/log/EC_ee282.log
#SBATCH --ntasks=1
#SBATCH --account=ALLISONS_LAB
#SBATCH --mem=50gb
#SBATCH --cpus-per-task=8
#SBATCH --time=01:00:00
#SBATCH --mail-user=xkhoo@uci.edu
#SBATCH --mail-type=BEGIN,FAIL,END

# Activate the environment
source ~/.bashrc
conda activate ee282
umask g+rwx

FCONTIG="output/reports/homework4/assembly/dmel_contigs_from_scaffolds.fa"
ISO1="output/reports/homework4/assembly/iso1.dm.asm.bp.p_ctg.fa"

OUTDIR="output/reports/homework4/extra_credit"
mkdir -p "$OUTDIR"
PLOT_OUTDIR="output/figures/homework4/extra_credit"
mkdir -p "$PLOT_OUTDIR"

# Align the iso1 assembly to the flybase contig ref
nucmer --delta="${OUTDIR}/iso1_vs_flybase_contig.delta" \
       -t 4 \
       "$FCONTIG" \
       "$ISO1"

# Keep a 1-to-1 best alignment set
delta-filter -1 "${OUTDIR}/iso1_vs_flybase_contig.delta" > "${OUTDIR}/iso1_vs_flybase_contig.1delta"

# Plot using mummer
mummerplot -t png \
  --layout \
  -R "$FCONTIG" \
  -Q "$ISO1" \
  --filter \
  -title "Comparison between iso-1 strain and FlyBase contig assembly" \
  -p "${PLOT_OUTDIR}/iso1_vs_flybase_contig" \
  "${OUTDIR}/iso1_vs_flybase_contig.1delta"

