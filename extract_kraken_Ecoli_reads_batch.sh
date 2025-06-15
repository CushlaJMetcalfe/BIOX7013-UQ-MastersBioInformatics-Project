#!/bin/bash

# Set directories
script_dir="/home.roaming/s4662374/scripts"
base_dir="/mnt/data/cushla/gutmeta"
fastq_dir="${base_dir}/sequencing/passQC_reads/3a_filter_human"
kraken_dir="${base_dir}/analysis/4a_kraken"
ecoli_dir="${base_dir}/analysis/8a_Ecoli_extract"

# Submit jobs for all forward and reverse read pairs


for f in ${kraken_dir}/*_kraken2.output.txt; do
	r="${f/_kraken2.output.txt/_kraken2.report.txt}"
    	s1="${f/_kraken2.output.txt/_1.filter.fastq.gz}"
	s2="${f/_kraken2.output.txt/_2.filter.fastq.gz}"
	id=$(basename "${f/_kraken2.output.txt/}")
	echo "id: $id"
	sbatch "${script_dir}/extract_kraken_Ecoli_reads.sh" \
		"$(basename $f)" \
		"$(basename $r)" \
		"$(basename $s1)" \
		"$(basename $s2)" \
		"$id" \
		"$fastq_dir" \
		"$kraken_dir" \
		"$ecoli_dir"
done
