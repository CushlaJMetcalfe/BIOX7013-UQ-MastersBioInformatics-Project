#!/bin/bash

# Run kraken.sh for selected fastq.gz files

# Set directories
script_dir="/home.roaming/s4662374/scripts"
in_dir="/mnt/data/cushla/gutmeta/sequencing/passQC_reads/3a_filter_human"
out_dir="/mnt/data/cushla/gutmeta/analysis/4a_kraken"

# Submit jobs for all forward and reverse read pairs
for f in ${in_dir}/*_1.filter.fastq.gz; do
    r="${f/_1.filter.fastq.gz/_2.filter.fastq.gz}"  # Reverse read
    id=$(basename "${f/_1.filter.fastq.gz/}")  # Sample ID

    echo "Submitting job for: $id"
    sbatch "${script_dir}/kraken.sh" "$(basename $f)" "$(basename $r)" "$id" "$in_dir" "$out_dir"

done

