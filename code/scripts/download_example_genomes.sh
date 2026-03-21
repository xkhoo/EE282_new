#!/usr/bin/bash
OUTDIR="data/raw/final_project_example_genomes"
mkdir -p "$OUTDIR"
# Download 5 example bacterial whole genomes from NCBI
# 1. Burkholderia glumae LMG 2196 = ATCC 33617
BG="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/960/995/GCF_000960995.1_ASM96099v1/GCF_000960995.1_ASM96099v1_genomic.fna.gz"
wget -O "${OUTDIR}/GCF_000960995.1_ASM96099v1_genomic.fna.gz" "$BG"

# 2. Pseudomonas putida NBRC 14164
PP="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/412/675/GCF_000412675.1_ASM41267v1/GCF_000412675.1_ASM41267v1_genomic.fna.gz"
wget -O "${OUTDIR}/GCF_000412675.1_ASM41267v1_genomic.fna.gz" "$PP"

# 3. Pseudomonas cichorii
PC="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/018/343/775/GCF_018343775.1_ASM1834377v1/GCF_018343775.1_ASM1834377v1_genomic.fna.gz"
wget -O "${OUTDIR}/GCF_018343775.1_ASM1834377v1_genomic.fna.gz" "$PC"

# 4. Pseudomonas nunensis
PN="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/024/296/925/GCF_024296925.1_ASM2429692v1/GCF_024296925.1_ASM2429692v1_genomic.fna.gz"
wget -O "${OUTDIR}/GCF_024296925.1_ASM2429692v1_genomic.fna.gz" "$PN"

# 5. Rhizobium etli CFN 42
RE="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/092/045/GCF_000092045.1_ASM9204v1/GCF_000092045.1_ASM9204v1_genomic.fna.gz"
wget -O "${OUTDIR}/GCF_000092045.1_ASM9204v1_genomic.fna.gz" "$RE"

# Perform checksum on all these files before unzipping
md5sum "${OUTDIR}"/*.gz > "output/reports/final_project/genome_md5_checksums.txt"
cat "output/reports/final_project/genome_md5_checksums.txt"

# Unzip all these genomes
gunzip "${OUTDIR}"/*.gz


##############################
# For metadata preprocessing (my actual data from JGI)
##############################

# The number of MAGs available for download in the download link did not match my download request due to missing metadata in the JGI portal
# I need to exclude these MAGs from my metadata
# Rhizosphere MAGs are on the hpc so I can retrieve the downloaded MAG id using the following command
GENOME_DIR="/pub/xkhoo/MAGS/mb_rhizosphere/genomes"

{
  echo "Bin.ID"
  find "$GENOME_DIR" -type f \( -name "*.fna" -o -name "*.fa" -o -name "*.fasta" -o -name "*.fna.gz" -o -name "*.fa.gz" -o -name "*.fasta.gz" \) \
    | sed 's|.*/||' \
    | sed -E 's/\.(fna|fa|fasta)(\.gz)?$//' \
    | sort
} > "output/reports/final_project/downloaded_rhizo_mag_ids.txt"
# Soil MAGs are only available on my local hard disk due to limited space on hpc, so the ids.txt will be uploaded as `output/reports/final_project/downloaded_soil_mag_ids.txt`

