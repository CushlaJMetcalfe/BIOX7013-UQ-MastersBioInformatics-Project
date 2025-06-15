#!/bin/bash

# Run fastp on all files that timed out during first fastp job run
# with increased time limit


# Set directories and files
script_dir="/home.roaming/s4662374/scripts"
in_dir="/mnt/data/gmrepo/Curated"
out_dir="/mnt/data/cushla/gutmeta/sequencing/passQC_reads/1a_fastp_rerun"
list_file="/mnt/data/cushla/gutmeta/reports/fastp_cancelled_samples.txt"


# Submit jobs for all forward and reverse read pairs
while IFS= read -r line; do
	id=$(basename "${line/_1/}")
    	forward=$"${id}_1.fastq.gz"
    	reverse=$"${id}_2.fastq.gz"  # Reverse read
    	echo "Submittimg job for sequence: $id"
    	echo "forward read: $forward"
    	echo "reverse read: $reverse"
    	sbatch "${script_dir}/fastp.sh" \
	"$(basename "$forward")" \
	"$(basename "$reverse")" \
	"$id" "$in_dir" "$out_dir"
done < "$list_file"
