# Homework3: Pipelines for generating genome and annotation summaries of _Drosophila melanogaster_ 

## Required environment
- ```bash
  conda activate ee282
  ```

## Scripts needed for pipelines
- Data retrieval script: `code/scripts/hw3_data`
- Genome summary script: `code/scripts/hw3_genome_summary.sh`
- Annotation summary script: `code/scripts/hw3_annotation_gtf.gz`

## Retrieve fasta and annotation files from the database (FlyBase)
### All chromosome genome file
```bash
wget -O data/raw/dmel_all_chromosomes.fasta.gz https://s3ftp.flybase.org/genomes/Drosophila_melanogaster/dmel_r6.66_FB2025_05/fasta/dmel-all-chromosome-r6.66.fasta.gz
```
### Annotation GTF file
```bash
wget -O data/raw/dmel_annotation.gtf.gz https://s3ftp.flybase.org/genomes/Drosophila_melanogaster/dmel_r6.66_FB2025_05/gtf/dmel-all-r6.66.gtf.gz
```

## Part I: Summarize Genome Assembly
### A. All chromosome genome file integrity (checksum)

Checksum file: 
- `output/reports/homework3/dmel_all_chromosomes.fasta.gz.md5`

Command used:
```bash
md5sum data/raw/dmel_all_chromosomes.fasta.gz
````

Output:
```text
ccb86e94117eb4eeaaf70efb6be1b6b9  data/raw/dmel_all_chromosomes.fasta.gz
```

### B. Calculate summaries of the genome

Command used:
```bash
faSize data/raw/dmel_all_chromosomes.fasta.gz
```

Output from `output/reports/homework3/genome_faSize_summary.txt`:
- Total number of nucleotides: 143,726,002
- Total number of N's: 1,152,978
- Total number of sequences: 1,870 

## Part II: Summarize an Annotation File
### A. Annotation GTF file integrity (checksum)

Checksum file:
- `output/reports/homework3/dmel_annotation.gtf.gz.md5`

Command used:
```bash
md5sum data/raw/dmel_annotation.gtf.gz
```

Output:
```text
ea600dbb86f1779463f69082131753cd  data/raw/dmel_annotation.gtf.gz
```

### B. Compile a report summarizing the annotation
#### 1) Total number of feature counts by type (from most common to least common)

Command used:
```bash
bioawk -c gff '{print $feature}' data/raw/dmel_annotation.gtf.gz \
 | sort \
 | uniq -c \
 | sort -nr
```
- `bioawk -c gff '{print $feature}' ...` extracts the feature type field (e.g., gene, exon, CDS) from each GTF record.
- `sort` groups identical feature names together.
- `uniq -c` counts the frequency of each feature type.
- `sort -nr` sorts counts numerically in descending order.

Output saved to: 
- `output/reports/homework3/annotation_feature_type_counts.txt`

```text
 190176 exon
 163377 CDS
  46856 5UTR
  33778 3UTR
  30922 start_codon
  30862 stop_codon
  30836 mRNA
  17872 gene
   3059 ncRNA
    485 miRNA
    365 pseudogene
    312 tRNA
    270 snoRNA
    262 pre_miRNA
    115 rRNA
     32 snRNA
```

#### 2) Total number of genes per chromosome arm (X, Y, 2L, 2R, 3L, 3R, 4)

Command used:
```bash
bioawk -c gff '$feature=="gene" {print $seqname}' data/raw/dmel_annotation.gtf.gz \
  |grep -E '^(X|Y|2L|2R|3L|3R|4)$' \
  | sort \
  | uniq -c \
  | sort -nr
```
- `bioawk -c gff '$feature=="gene" {print $seqname}' ...` keeps only `gene` features and prints the chromosome arm name.
- `grep -E` pulls/restricts to only the required arms (X, Y, 2L, 2R, 3L, 3R, 4).
- `sort | uniq -c | sort -nr` counts genes per arm and sorts them from most to least.
 
Output saved to:
- `output/reports/homework3/annotation_genes_per_arm.txt`

```text
   4226 3R
   3649 2R
   3508 2L
   3481 3L
   2704 X
    114 4
    113 Y
```
