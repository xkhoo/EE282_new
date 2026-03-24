#!/usr/bin/bash

FASTA_FILE="data/raw/dmel_all_chromosomes.fasta.gz"
OUTDIR="output/reports/homework3"
mkdir -p "$OUTDIR"

echo "## Genome Assembly: FASTA file integrity ##"
md5sum "$FASTA_FILE" | tee "$OUTDIR/dmel_all_chromosomes.fasta.gz.md5"

echo
echo "## Genome Assembly: faSize summary ##"
# run faSize on the zip file
faSize "$FASTA_FILE" | tee "$OUTDIR/genome_faSize_summary.txt"

echo
echo "Saved:"
echo "  $OUTDIR/dmel_all_chromosomes.fasta.gz.md5"
echo "  $OUTDIR/genome_faSize_summary.txt"
