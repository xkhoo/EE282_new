# Homework 4: Genome partition summary, assembly, assessment, plotting, and extra credit

## Required environment
- For most parts:
```bash
  conda activate ee282
```
- For the BUSCO part:
```bash
  conda activate busco
```
## Summarize partitions of a genome assembly ([hw4_genome_summary.sh](code/scripts/hw4_genome_summary.sh))
### A. Calculate the following for all sequences ≤ 100kb
- Command used: 
```bash 
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
```
- `FASTA_FILE="data/raw/dmel_all_chromosomes.fasta.gz"`
- `OUTDIR="output/reports/homework4"`

Output from `output/reports/homework4/shorter_100kb_summary.tsv`:
1. Total number of nucleotides : 6,178,042
2. Total number of Ns          : 1,863
3. Total number of sequences   : 1,863

### B. Calculate the following for all sequences > 100kb
- Command used:
```bash
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
```

Output from `output/reports/homework4/longer_100kb_summary.tsv`:
1. Total number of nucleotides : 137,547,960
2. Total number of Ns          : 490,385
3. Total number of sequences   : 7

## Generate plots for partitions of a genome assembly
- The histograms generated for the sequence length distribution and sequence GC% distribution were performed in [hw4_genome_plot_histogram.R](code/scripts/hw4_genome_plot_histogram.R).
- The estimation of GC content and the cumulative sequence size plots were performed in [hw4_genome_plot_input.sh](code/scripts/hw4_genome_plot_input.sh). 

### A. Plotting all sequences ≤ 100kb
- Files used in R:
```R
short <- read.delim("output/reports/homework4/shorter_100kb_gc.tsv", sep = "\t", header = TRUE)
long  <- read.delim("output/reports/homework4/longer_100kb_gc.tsv", sep = "\t", header = TRUE)
```
#### 1. Sequence length distribution
- Command used: 
```R
p1 <- ggplot(short, aes(x = length)) +
  geom_histogram(bins = 40) +
  scale_x_log10() +
  labs(
    title = "Sequence length distribution (<=100 kb)",
    x = "Sequence length (log10 scale)",
    y = "Count"
  ) +
  theme_bw(base_size = 16)

ggsave("output/figures/homework4/shorter_100kb_length_hist.png", p1, width = 7, height = 5)
```
The sequence length distribution plot for all sequences ≤ 100kb was saved as `output/figures/homework4/shorter_100kb_length_hist.png`.

#### 2. Sequence GC% distribution
a. Calculate the sequence GC%
```bash
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
```
- `FASTA_FILE="data/raw/dmel_all_chromosomes.fasta.gz"`
- `OUTDIR="output/reports/homework4"`

The table with GC% information for all sequences ≤ 100kb was saved as `output/reports/homework4/shorter_100kb_gc.tsv`.

b. Plot the GC% distribution in R:
```R
p2 <- ggplot(short, aes(x = gc)) +
  geom_histogram(bins = 30) +
  labs(
    title = "GC distribution (<=100 kb)",
    x = "GC",
    y = "Count"
  ) +
  theme_bw(base_size = 16)

ggsave("output/figures/homework4/shorter_100kb_gc_hist.png", p2, width = 7, height = 5)
```
The sequence GC% distribution plot for all sequences ≤ 100kb was saved as `output/figures/homework4/shorter_100kb_gc_hist.png`. 

#### 3. Cumulative sequence size (sorted from largest to smallest sequences)
- Command used:
```bash
# Prepare the plotCDF2 input with Length and Assembly header
{
  gawk 'BEGIN {
    print "Length\tAssembly"
    print "0\t<=100kb"
  }'
  gawk 'NR>1 {print $2 "\t<=100kb"}' "${OUTDIR}/shorter_100kb_gc.tsv" | sort -k1,1nr
} > "${OUTDIR}/shorter_100kb_cdf.tsv"

# PlotCDF2
../../informatics_class/bin/plotCDF2 "${OUTDIR}/shorter_100kb_cdf.tsv" "${PLOT_OUTDIR}/shorter_100kb_cdf.png"
```
- `OUTDIR="output/reports/homework4"`
- `PLOT_OUTDIR="output/figures/homework4"`

The cumulative sequence size plot for all sequences ≤ 100kb was saved as `output/figures/homework4/shorter_100kb_cdf.png`

### B. Plotting all sequences > 100kb  
#### 1. Sequence length distribution
- Command used:
```R
p3 <- ggplot(long, aes(x = length)) +
  geom_histogram(bins = 30) +
  scale_x_log10() +
  labs(
    title = "Sequence length distribution (>100 kb)",
    x = "Sequence length (log10 scale)",
    y = "Count"
  )+
  theme_bw(base_size = 16)

ggsave("output/figures/homework4/longer_100kb_length_hist.png", p3, width = 7, height = 5)
```
The sequence length distribution plot for all sequences > 100kb was saved as `output/figures/homework4/longer_100kb_length_hist.png`.

#### 2. Sequence GC% distribution
a. Calculate the sequence GC%
```bash
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
```
The table with GC% information for all sequences > 100kb was saved as `output/reports/homework4/longer_100kb_gc.tsv`.

b. Plot the GC% distribution in R:
```R
p4 <- ggplot(long, aes(x = gc)) +
  geom_histogram(bins = 30) +
  labs(
    title = "GC distribution (>100 kb)",
    x = "GC",
    y = "Count"
  ) +
  theme_bw(base_size = 16)

ggsave("output/figures/homework4/longer_100kb_gc_hist.png", p4, width = 7, height = 5)
```
The sequence GC% distribution plot for all sequences ≤ 100kb was saved as `output/figures/homework4/longer_100kb_gc_hist.png`. 

#### 3. Cumulative sequence size (sorted from largest to smallest sequences)
```bash
# Prepare the plotCDF2 input with Length and Assembly header
{
  gawk 'BEGIN {
    print "Length\tAssembly"
    print "0\t>100kb"
  }'
  gawk 'NR>1 {print $2 "\t>100kb"}' "${OUTDIR}/longer_100kb_gc.tsv" | sort -k1,1nr
} > "${OUTDIR}/longer_100kb_cdf.tsv"

# PlotCDF2
../../informatics_class/bin/plotCDF2 "${OUTDIR}/shorter_100kb_cdf.tsv" "${PLOT_OUTDIR}/shorter_100kb_cdf.png"
```
The cumulative sequence size plot for all sequences ≤ 100kb was saved as `output/figures/homework4/longer_100kb_cdf.png`.

## Genome assembly
### A. Assemble iso-1 _Drosophila melanogaster_ using Pacbio HiFi reads
#### 1. On HPC3, download the reads to the `data/raw` directory using the following command:
```bash
cp /pub/jje/ee282/ISO_HiFi_Shukla2025.fasta.gz data/raw
```
#### 2. Use _hifiasm_ to assemble reads by submitting the script ([hw4_genome_assembly.sh](code/scripts/hw4_genome_assembly.sh))
```bash
hifiasm -t 16 -o "${OUTDIR}/iso1.dm.asm" "${READS}"
```
- `DATADIR="data/raw"`
- `READS="${DATADIR}/ISO_HiFi_Shukla2025.fasta.gz"`
- `OUTDIR="output/reports/homework4/assembly"`

A total of 18 files with the prefix `iso1.dm.asm` were saved to `output/reports/homework4/assembly`. The assembly output (`iso1.dm.asm.bp.p_ctg.gfa`) was treated as the main assembly going forward. The `.gfa` output was converted to `.fa` before proceeding to the assessment step using the command:
```bash
gfatools gfa2fa "${OUTDIR}/iso1.dm.asm.bp.p_ctg.gfa" > "${OUTDIR}/iso1.dm.asm.bp.p_ctg.fa"
```
- `OUTDIR="output/reports/homework4/assembly"`

### B. Assembly assessment
#### 1. N50 assessment [hw4_genome_assembly_assessment.sh](code/scripts/hw4_genome_assembly_assessment.sh).
a) Calculate the N50 of the iso-1 assembly 
Command used:
```bash
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
```
- `OUTDIR="output/reports/homework4/assembly"`
- `ISO1="${OUTDIR}/iso1.dm.asm.bp.p_ctg.fa"`

Output from `output/reports/homework4/assembly/assembly_n50.tsv`: 21,715,751

b) Compare the output from **1a** to the contig N50 of [_Drosophila_ community reference](https://www.ncbi.nlm.nih.gov/datasets/genome/GCF_000001215.4/)
- _Drosophila_ community reference N50 = 21,485,538
- iso1 assembly N50 = 21,715,751

The N50 of the primary contig of iso1 assembly is slightly longer than the _Drosophila_ community reference by **230,213** bp.

#### 2. Compare iso-1 assembly to both the contig assembly and the scaffold assembly from the _Drosophila melanogaster_ on FlyBase using a contiguity plot [hw4_genome_assembly_assessment.sh](`code/scripts/hw4_genome_assembly_assessment.sh`).
a) Prepare the FlyBase contig assembly (FCONTIG) using the following command:
```bash  
zcat "$FSCAFF" \
| ../../informatics_class/bin/faSplitByN /dev/stdin /dev/stdout 10 \
> "${OUTDIR}/dmel_contigs_from_scaffolds.fa"
FCONTIG="${OUTDIR}/dmel_contigs_from_scaffolds.fa"
```
- `OUTDIR="output/reports/homework4/assembly"`

b) Prepare the plotCDF2 input using the following command:
```bash
gawk 'BEGIN { print "Length\tAssembly" }' > "${OUTDIR}/Iso1_vs_flybase_contig_scaffold.tsv"

{
  printf "0\tIso1_Assembly\n"
  bioawk -c fastx '{ print length($seq) "\tIso1_Assembly" }' "$ISO1" | sort -k1,1nr

  printf "0\tFlyBase_Contig\n"
  bioawk -c fastx '{ print length($seq) "\tFlyBase_Contig" }' "$FCONTIG" | sort -k1,1nr

  printf "0\tFlyBase_Scaffold\n"
  bioawk -c fastx '{ print length($seq) "\tFlyBase_Scaffold" }' "$FSCAFF" | sort -k1,1nr
} >> "${OUTDIR}/Iso1_vs_flybase_contig_scaffold.tsv"
```
- `ISO1="${OUTDIR}/iso1.dm.asm.bp.p_ctg.fa"`
- `FSCAFF="data/raw/dmel_all_chromosomes.fasta.gz"`

c) Generate the contiguity plot
```bash
../../informatics_class/bin/plotCDF2 \
  "${OUTDIR}/Iso1_vs_flybase_contig_scaffold.tsv" \
  "${PLOT_OUTDIR}/Iso1_vs_flybase_contig_scaffold_contiguity_plot.png"
```
- `PLOT_OUTDIR="output/figures/homework4"`

The contiguity plot was saved as `output/figures/homework4/Iso1_vs_flybase_contig_scaffold_contiguity_plot.png`.

#### 3. Calculate BUSCO scores of both assemblies and compare them.
a) Activate the BUSCO environment as specified in the **Required environment** section.
b) BUSCO was run on both the iso-1 assembly and the FlyBase assembly using the `drosophila_odb12` lineage dataset, which contains 9,348 conserved single-copy ortholog groups (n = 9,348). The BUSCO assessment for both assemblies was performed by submitting the script ([hw4_genome_assembly_busco.sh](code/scripts/hw4_genome_assembly_busco.sh)):
```bash
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
```
- `OUTDIR="output/reports/homework4/assembly/busco"`
- `ISO1="output/reports/homework4/assembly/iso1.dm.asm.bp.p_ctg.fa"`
- `FSCAFF="data/raw/dmel_all_chromosomes.fasta.gz"`

c) BUSCO outputs
| Assembly | BUSCO dataset | Complete | Single-copy | Duplicated | Fragmented | Missing | Output file |
|:---|:---|---:|---:|---:|---:|---:|:---:|
| iso-1 assembly | drosophila_odb12 (n=9,348) | 99.9% (9,337) | 99.6% (9,311) |0.3% (26) | 0.0% (1) | 0.1% (10) | [short_summary.specific.drosophila_odb12.iso1_busco.txt](output/reports/homework4/assembly/busco/iso1_busco/short_summary.specific.drosophila_odb12.iso1_busco.txt) |
| FlyBase scaffold assembly | drosophila_odb12 (n=9,348) | 100% (9,346) | 99.7% (9,316) | 0.3% (30) | 0.0% (0) | 0.0% (2) | [short_summary.specific.drosophila_odb12.flybase_scaff_busco.txt](output/reports/homework4/assembly/busco/flybase_scaff_busco/short_summary.specific.drosophila_odb12.flybase_scaff_busco.txt) |

_Values in (parentheses) indicate the number of BUSCO groups in each category._

- Of the 9,337 complete BUSCOs in the iso-1 assembly, 147 contained internal stop codons (E= 1.6%).
- Of the 9,346 complete BUSCOs in the FlyBase scaffold assembly, 147 contained internal stop codons (E=1.6%). 

When assessed with the `drosophila_odb12` lineage dataset, the iso-1 assembly recovered 99.9% of BUSCO groups, while the FlyBase scaffold assembly recovered 100%. This indicates both assemblies were highly complete and they both contained nearly all expected conserved single-copy orthologs. 147 complete BUSCOs in each assembly contained internal stop codons, suggesting that a small fraction of recovered genes may contain prediction artifacts. Both assemblies had high assembly quality, as indicated by their low duplication, fragmentation, and missingness. However, FlyBase scaffold assembly performed slightly better, with no fragmented and fewer missing BUSCOs. 

## Extra Credit: Compare the iso-1 assembly to the contig assembly from _Drosophila melanogaster_ on FlyBase using a dotplot constructed with _MUMmer_ ([hw4_extra_credit.sh](code/scripts/hw4_extra_credit.sh))
a) Align the iso-1 assembly to the FlyBase contig assembly using `nucmer` with 4 threads and save the alignments in a delta file
```bash
nucmer --delta="${OUTDIR}/iso1_vs_flybase_contig.delta" \
       -t 4 \
       "$FCONTIG" \
       "$ISO1"
```
- `OUTDIR="output/reports/homework4/extra_credit"`
- `FCONTIG="output/reports/homework4/assembly/dmel_contigs_from_scaffolds.fa"`
- `ISO1="output/reports/homework4/assembly/iso1.dm.asm.bp.p_ctg.fa"`

b) The delta file produced by `nucmer` stores the pairwise alignment results between the two assemblies in a custom format, including the names of matching sequences, alignment length, numbers of errors, and positions of indels (Marçais et al. 2018). The delta file was then filtered with:

- `delta-filter -1` to retain only the best one-to-one alignments, so that each region of the reference and query was mapped uniquely, while still allowing rearrangements such as inversions or translocations. The result was saved as `iso1_vs_flybase_contig.1delta`
```bash
delta-filter -1 "${OUTDIR}/iso1_vs_flybase_contig.delta" > "${OUTDIR}/iso1_vs_flybase_contig.1delta"
```
- `delta-filter -m` to retain many-to-many alignments, allowing regions in the reference to align to multiple regions in the query and vice versa, while still allowing rearrangements. The result was saved as `iso1_vs_flybase_contig.many.delta`
```bash
delta-filter -m "${OUTDIR}/iso1_vs_flybase_contig.delta" > "${OUTDIR}/iso1_vs_flybase_contig.many.delta"
```

c) The filtered delta files were then visualized using `mummerplot` to compare the alignment patterns between the iso-1 assembly and the FlyBase contig assembly. The `iso1_vs_flybase_contig.1delta` file was plotted to show the best one-to-one alignments, whereas `iso1_vs_flybase_contig.many.delta` was plotted to show the many-to-many alignments.
```bash
# 1-to-1 best alignment plot
mummerplot -t png \
  --layout \
  -R "$FCONTIG" \
  -Q "$ISO1" \
  -title "Comparison between iso-1 strain and FlyBase contig assembly (best one-to-one alignments)" \
  -p "${PLOT_OUTDIR}/iso1_vs_flybase_contig_best" \
  "${OUTDIR}/iso1_vs_flybase_contig.1delta"

# many-to-many alignment plot
mummerplot -t png \
  --layout \
  -R "$FCONTIG" \
  -Q "$ISO1" \
  -title "Comparison between iso-1 strain and FlyBase contig assembly (many-to-many alignments)" \
  -p "${PLOT_OUTDIR}/iso1_vs_flybase_contig_many" \
  "${OUTDIR}/iso1_vs_flybase_contig.many.delta"
```
- `PLOT_OUTDIR="output/figures/homework4/extra_credit"`

The final dotplots showing the best one-to-one alignments and the many-to-many alignments between the iso-1 assembly and the FlyBase contig assembly were saved as `iso1_vs_flybase_contig_best.png` and `iso1_vs_flybase_contig_many.png`, respectively. The `iso1_vs_flybase_contig_best.png` dotplot shows that the iso-1 assembly aligned strongly with the FlyBase contig assembly, as most alignments fell along positive diagonal blocks. The fragmented pattern of these alignment blocks was consistent with the contig-level nature of the FlyBase assembly. The `iso1_vs_flybase_contig_many.png` dotplot shows the same overall positive diagonal structure but it contained more off-diagonal dots and dense clusters of alignments. These extra alignments reflected the retention of multiple valid matches in the many-to-many filtering step and likely arose from repetitive, duplicated, or fragmented regions.     

## References
Marçais G, Delcher AL, Phillippy AM, Coston R, Salzberg SL, Zimin A. 2018. MUMmer4: A fast and versatile genome alignment system. PLoS Comput Biol 14: e1005944.
