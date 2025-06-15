#!/bin/bash

# Run filter_human.sh for selected fastq.gz files

# Set directories
script_dir="/home.roaming/s4662374/scripts"
in_dir="/mnt/data/cushla/gutmeta/sequencing/passQC_reads/1a_fastp"
out_dir="/mnt/data/cushla/gutmeta/sequencing/passQC_reads/3a_filter_human"

# Submit jobs for all forward and reverse read pairs
for f in ${in_dir}/*_1.fastp.fastq.gz; do
    r="${f/_1.fastp.fastq.gz/_2.fastp.fastq.gz}"  # Reverse read
    id=$(basename "${f/_1.fastp.fastq.gz/}")  # Sample ID
    echo "Submitting job for: $id"
    sbatch "${script_dir}/filter_human.sh" "$(basename $f)" "$(basename $r)" "$id" "$in_dir" "$out_dir"

done
