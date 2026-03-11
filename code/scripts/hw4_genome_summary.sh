#!/usr/bin/bash

FASTA_FILE="data/raw/dmel_all_chromosomes.fasta.gz"
OUTDIR="output/reports/homework4"
mkdir -p "${OUTDIR}"

# Calculation for all sequences ≤ 100kb
bioawk -c fastx '
{
  len=length($seq)
  if (len <= 100000) {
    nseq += 1
    nt += len
    s =$seq
    gsub(/[^Nn]/,"",s)
    ncount += length(seq)
  }
}
END {
  print "partition\tshorter_100kb"
  print "total_nucleotides\t" nt
  print "total_Ns\t" ncount
  print "total_sequences\t" nseq
}' "${FASTA_FILE}" > "${OUTDIR}/shorter_100kb_summary.tsv"

# Calculation for all sequences > 100kb
bioawk -c fastx '
{
  len=length($seq)
  if (len > 100000) {
    nseq += 1
    nt += len
    s =$seq
    gsub(/[^Nn]/,"",s)
    ncount += length(s)
  }
}
END {
  print "partition\tlonger_100kb"
  print "total_nucleotides\t" nt
  print "total_Ns\t" ncount
  print "total_sequences\t" nseq
}' "${FASTA_FILE}" > "${OUTDIR}/longer_100kb_summary.tsv"
