#!/bin/bash

# Run bracken.sh for selected kraken2.report files

# Set directories
script_dir="/home.roaming/s4662374/scripts"
base_dir="/mnt/data/cushla/gutmeta/analysis"
in_dir="${base_dir}/4a_kraken"
out_dir="${base_dir}/5a_bracken"

# Submit jobs for all kraken2 output reports
for f in ${in_dir}/*_kraken2.report.txt; do # kraken report including directory structure
	id=$(basename "${f/_kraken2.report.txt/}")  # Sample ID
	sbatch "${script_dir}/bracken.sh" "$id" "$in_dir" "$out_dir"
done
