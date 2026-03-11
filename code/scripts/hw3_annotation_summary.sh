#!/usr/bin/bash

GTF_FILE="data/raw/dmel_annotation.gtf.gz"
OUTDIR="output/reports/homework3"

echo "## Annotation: GTF file integrity ##"
md5sum "$GTF_FILE" | tee "$OUTDIR/dmel_annotation.gtf.gz.md5"

echo
echo "## Total number of feature counts by type (from most common to least common) ##"
# In bioawk -c gff, $feature is the 3rd column (type)
bioawk -c gff '{print $feature}' "$GTF_FILE" \
  | sort \
  | uniq -c \
  | sort -nr \
  | tee "$OUTDIR/annotation_feature_type_counts.txt"

echo
echo "## Total number of genes per chromosome arm (X, Y, 2L, 2R, 3L, 3R, 4) ##"
# Count only gene features, tabulate by chromosome/arm ($seqname)
bioawk -c gff '$feature=="gene" {print $seqname}' "$GTF_FILE" \
  | grep -E '^(X|Y|2L|2R|3L|3R|4)$' \
  | sort \
  | uniq -c \
  | sort -nr \
  | tee "$OUTDIR/annotation_genes_per_arm.txt"

echo
echo "Saved:"
echo "  $OUTDIR/dmel_annotation.gtf.gz.md5"
echo "  $OUTDIR/annotation_feature_type_counts.txt"
echo "  $OUTDIR/annotation_genes_per_arm.txt"
