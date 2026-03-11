#!/usr/bin/bash

FASTA_FILE="data/raw/dmel_all_chromosomes.fasta.gz"
OUTDIR="output/reports/homework4"
PLOT_OUTDIR="output/figures/homework4"
mkdir -p "$PLOT_OUTDIR"

# Calculate GC content for all sequences ≤ 100kb
{
  printf "seqname\tlength\tgc\n"
  bioawk -c fastx '
  {
    len = length($seq)
    if (len <= 100000) {
      print $name "\t" len "\t" gc($seq)
    }
  }' "${FASTA_FILE}"
} > "${OUTDIR}/shorter_100kb_gc.tsv"


# Calculate GC content for all sequences > 100kb
{
  printf "seqname\tlength\tgc\n"
  bioawk -c fastx '
  {
    len = length($seq)
    if (len > 100000) {
      print $name "\t" len "\t" gc($seq)
    }
  }' "${FASTA_FILE}"
} > "${OUTDIR}/longer_100kb_gc.tsv"

# Prepare input for plotCDF2
# Partition 1: all sequences ≤ 100kb
{
  gawk 'BEGIN {
    print "Length\tAssembly"
    print "0\t<=100kb"
  }'
  gawk 'NR>1 {print $2 "\t<=100kb"}' "${OUTDIR}/shorter_100kb_gc.tsv" | sort -k1,1nr
} > "${OUTDIR}/shorter_100kb_cdf.tsv"

# Partition 2: all sequences > 100kb
{
  gawk 'BEGIN {
    print "Length\tAssembly"
    print "0\t>100kb"
  }'
  gawk 'NR>1 {print $2 "\t>100kb"}' "${OUTDIR}/longer_100kb_gc.tsv" | sort -k1,1nr
} > "${OUTDIR}/longer_100kb_cdf.tsv"

# Plot Cumulative sequence size using plotCDF2
# Shorter than 100kb partition:
../../informatics_class/bin/plotCDF2 "${OUTDIR}/shorter_100kb_cdf.tsv" "${PLOT_OUTDIR}/shorter_100kb_cdf.png"
# Longer than 100kb partition:
../../informatics_class/bin/plotCDF2 "${OUTDIR}/longer_100kb_cdf.tsv" "${PLOT_OUTDIR}/longer_100kb_cdf.png"
