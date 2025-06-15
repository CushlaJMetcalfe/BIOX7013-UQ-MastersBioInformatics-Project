#!/bin/bash

# Run fastp.sh for selected fastq.gz files

# Set directories
script_dir="/home.roaming/s4662374/scripts"
in_dir="/mnt/data/gmrepo/Curated"
out_dir="/mnt/data/cushla/gutmeta/sequencing/passQC_reads/1a_fastp"
 
# Submit jobs for all forward and reverse read pairs
for f in ${in_dir}/*_1.fastq.gz; do
    r="${f/_1.fastq.gz/_2.fastq.gz}"  # Reverse read
    id=$(basename "${f/_1.fastq.gz/}")  # Sample ID
    echo "Submitting job for: $id"
    sbatch "${script_dir}/fastp.sh" "$(basename $f)" "$(basename $r)" "$id" "$in_dir" "$out_dir"
done
