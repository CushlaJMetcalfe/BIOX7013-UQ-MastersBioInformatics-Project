#!/bin/bash

# Set directories
script_dir="/home.roaming/s4662374/scripts"
in_dir="/mnt/data/cushla/gutmeta/analysis/5a_bracken_filtered"
out_dir="/mnt/data/cushla/gutmeta/analysis/6a_rarefaction_filtered"

# Submit jobs for all forward and reverse read pairs
for f in ${in_dir}/*.bracken.report.filtered.txt; do
    id=$(basename "${f/.bracken.report.filtered.txt/}")  # Sample ID
    echo "Submitting job for: $id"
    sbatch "${script_dir}/vegan_rarefaction.sh" "$script_dir" "$id" "$in_dir" "$out_dir"
done
