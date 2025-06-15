#!/bin/bash

# Set directories
script_dir="/home.roaming/s4662374/scripts"
base_dir="/mnt/data/cushla/gutmeta/analysis"
in_dir="${base_dir}/8a_Ecoli_extract"
out_dir="${base_dir}/9a_strainGST"
kmer=23

# Submit jobs for all forward and reverse read pairs

#sbatch "${script_dir}/straingst.sh"

for f in ${in_dir}/*_Ecolireads_1.fastq; do
	r="${f/_Ecolireads_1.fastq/_Ecolireads_2.fastq}"
	id=$(basename "${f/_Ecolireads_1.fastq/}")
	echo "id: $id"
	echo "in_dir: $in_dir"
	echo "out_dir: $out_dir"
	echo "forward ecoli reads: $f"
	echo "reverse ecoli reads: $r"
    	sbatch "${script_dir}/straingst.sh" \
		"$in_dir" \
		"$out_dir" \
		"$(basename $f)" \
		"$(basename $r)" \
		"$id"
done
