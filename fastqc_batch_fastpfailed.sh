#!/bin/bash

# Run fastqc on all .gz files that timed out during fastp 

# Set directories
script_dir="/home.roaming/s4662374/scripts"
in_dir="/mnt/data/cushla/gutmeta/sequencing/passQC_reads/1a_fastp_rerun"
out_dir="/mnt/data/cushla/gutmeta/sequencing/passQC_reads/1a_rerun_fastqc"


# Submit jobs for all forward and reverse read pairs
for f in ${in_dir}/*_1.fastp.fastq.gz; do
	r="${f/_1.fastp.fastq.gz/_2.fastp.fastq.gz}"  # Reverse read
	id=$(basename "${f/_1.fastp.fastq.gz/}")  # Sample ID
	echo "Submitting job for: $id"
	sbatch "${script_dir}/fastqc_fastpfailed.sh" "$(basename $f)" "$(basename $r)" "$id" "$in_dir" "$out_dir"
done
