#!/bin/bash

# Run fastqc on all raw.gz files that timed out during fastp

# Set directories
script_dir="/home.roaming/s4662374/scripts"
in_dir="/mnt/data/cushla/gutmeta/sequencing/raw_reads/raw_reads_failed"
out_dir="/mnt/data/cushla/gutmeta/sequencing/raw_reads/raw_reads_qc"

# Submit jobs for all forward and reverse read pairs
for f in ${in_dir}/*_1.fastq.gz; do
	r="${f/_1.fastq.gz/_2.fastq.gz}"  # Reverse read
	id=$(basename "${f/_1.fastq.gz/}")  # Sample ID
	echo "Submitting job for: $id"
	sbatch "${script_dir}/fastqc_rawfailed.sh" "$(basename $f)" "$(basename $r)" "$id" "$in_dir" "$out_dir"
done
