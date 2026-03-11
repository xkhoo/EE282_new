#!/usr/bin/bash
OUTDIR="output/reports/homework4/assembly"
PLOT_OUTDIR="output/figures/homework4/"

# Convert primary contig GFA to FASTA
gfatools gfa2fa "${OUTDIR}/iso1.dm.asm.bp.p_ctg.gfa" > "${OUTDIR}/iso1.dm.asm.bp.p_ctg.fa"

# PART 2: Assembly assessment
ISO1="${OUTDIR}/iso1.dm.asm.bp.p_ctg.fa"
FSCAFF="data/raw/dmel_all_chromosomes.fasta.gz"
# Obtain contig from scaffold
zcat "$FSCAFF" \
| ../../informatics_class/bin/faSplitByN /dev/stdin /dev/stdout 10 \
> "${OUTDIR}/dmel_contigs_from_scaffolds.fa"
FCONTIG="${OUTDIR}/dmel_contigs_from_scaffolds.fa"

# 2A. N50 calculation
bioawk -c fastx '{ print length($seq) }' "$ISO1" | sort -nr > "${OUTDIR}/assembly.lengths.txt"

total=$(awk '{s+=$1} END{print s}' "${OUTDIR}/assembly.lengths.txt")
half=$(awk -v t="$total" 'BEGIN{print t/2}')

awk -v half="$half" -v total="$total" '
{
  cum += $1
  if (cum >= half) {
    print "assembly_total_bp\t" total
    print "assembly_half_bp\t" half
    print "assembly_N50\t" $1
    exit
  }
}' "${OUTDIR}/assembly.lengths.txt" > "${OUTDIR}/assembly_n50.tsv"
# Compare to community reference: 25,286,936 bp

# 2B. Compare the iso1 assembly to Flybase contig and scaffold assembly
# Comparison between iso1 and FlyBase contig
gawk 'BEGIN { print "Length\tAssembly" }' > "${OUTDIR}/Iso1_vs_flybase_contigs.tsv"
{
  printf "0\tIso1_Assembly\n"
  bioawk -c fastx '{ print length($seq) "\tIso1_Assembly" }' "$ISO1"

  printf "0\tFlyBase_Contig\n"
  bioawk -c fastx '{ print length($seq) "\tFlyBase_Contig" }' "$FCONTIG"
} | sort -k1,1nr >> "${OUTDIR}/Iso1_vs_flybase_contigs.tsv"

../../informatics_class/bin/plotCDF2 \
  "${OUTDIR}/Iso1_vs_flybase_contigs.tsv" \
  "${PLOT_OUTDIR}/Iso1_vs_flybase_contigs.png"

# Comparison between iso1 and FlyBase scaffold
gawk 'BEGIN { print "Length\tAssembly" }' > "${OUTDIR}/Iso1_vs_flybase_scaffold.tsv"
{
  printf "0\tIso1_Assembly\n"
  bioawk -c fastx '{ print length($seq) "\tIso1_Assembly" }' "$ISO1"

  printf "0\tFlyBase_Scaffold\n"
  bioawk -c fastx '{ print length($seq) "\tFlyBase_Scaffold" }' "$FSCAFF"
} | sort -k1,1nr >> "${OUTDIR}/Iso1_vs_flybase_scaffold.tsv"

../../informatics_class/bin/plotCDF2 \
  "${OUTDIR}/Iso1_vs_flybase_scaffold.tsv" \
  "${PLOT_OUTDIR}/Iso1_vs_flybase_scaffold.png"

# Comparison between iso1 and FlyBase contig and scaffold
gawk 'BEGIN { print "Length\tAssembly" }' > "${OUTDIR}/Iso1_vs_flybase_contig_scaffold.tsv"

{
  printf "0\tIso1_Assembly\n"
  bioawk -c fastx '{ print length($seq) "\tIso1_Assembly" }' "$ISO1"

  printf "0\tFlyBase_Contig\n"
  bioawk -c fastx '{ print length($seq) "\tFlyBase_Contig" }' "$FCONTIG"

  printf "0\tFlyBase_Scaffold\n"
  bioawk -c fastx '{ print length($seq) "\tFlyBase_Scaffold" }' "$FSCAFF"
} | sort -k1,1nr >> "${OUTDIR}/Iso1_vs_flybase_contig_scaffold.tsv"

../../informatics_class/bin/plotCDF2 \
  "${OUTDIR}/Iso1_vs_flybase_contig_scaffold.tsv" \
  "${PLOT_OUTDIR}/Iso1_vs_flybase_contig_scaffold_contiguity_plot.png"
