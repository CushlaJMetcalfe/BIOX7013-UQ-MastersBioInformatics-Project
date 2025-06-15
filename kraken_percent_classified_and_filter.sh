#!/bin/bash
#SBATCH --job-name=kr_filter
#SBATCH --output=/mnt/data/cushla/gutmeta/reports/analysis/logs/s_kr_filter_%j.log
#SBATCH --error=/mnt/data/cushla/gutmeta/reports/analysis/logs/s_kr_filter_%j.err
#SBATCH --ntasks=1
#SBATCH --nodelist=alice
#SBATCH --cpus-per-task=1
#SBATCH --mem=16GB
#SBATCH --time=01:00:00

# set variables
script_dir="/home.roaming/s4662374/scripts"
kraken_dir="/mnt/data/cushla/gutmeta/analysis/4a_kraken" # input directory with .kraken2.log files
reports_dir="/mnt/data/cushla/gutmeta/reports/analysis" # output directory for all output files
cutoff=75 # percent classified cutoff 
output_csv_file="kraken_percent_classified.csv"  # python csv output file with sample name, percent classified
output_txt_file="kraken_failed_sample_names.txt"  # python txt output file with failed sample names only, 
			                          # i.e. samples with < cutoff classified
output_pdf_file="kraken_percent_classified_violin_plot.pdf" # R pdf output file for violin plot 

source activate py3

# run python script to get % classified from kraken log files
# and output 1. csv with sample name, % classified and 2. txt with failed sample names

echo "SLURM_JOB_ID: " $SLURM_JOB_ID
echo "SLURM_JOB_NODELIST: " $SLURM_JOB_NODELIST
echo "SLURMTMPDIR: " $SLURMTMPDIR
echo "Python: " $(which python3)
echo "Python VERSION: " $(python3 --version 2>&1 | sed 's/^[^ ]* //')


# run Python script
python ${script_dir}/kraken_percent_classified.py \
	--dir_in ${kraken_dir} \
	--dir_out ${reports_dir} \
	--cut_off ${cutoff} \
	--csv_file_out ${output_csv_file} \
	--txt_file_out ${output_txt_file} \
        > "${reports_dir}/logs/p_kraken_class_filter.out" \
        2> "${reports_dir}/logs/p_kraken_class_filter.err"


# run R script to remove failed samples from list and  
# produce violin plot of % classified by Kraken

conda deactivate

# activate environments
source activate r_vegan

echo "SLURM_JOB_ID: " $SLURM_JOB_ID
echo "SLURM_JOB_NODELIST: " $SLURM_JOB_NODELIST
echo "SLURMTMPDIR: " $SLURMTMPDIR
echo "R: " $(which R)
echo "R VERSION: " $(R --version 2>&1 | grep -oP '\d+\.\d+\.\d+')

# run R script
Rscript "${script_dir}/kraken_passed_samples_violinplot.R" \
        --input_csv_file "${reports_dir}/${output_csv_file}" \
        --input_txt_file "${reports_dir}/${output_txt_file}" \
	--output_pdf "${reports_dir}/${output_pdf_file}" \
        > "${reports_dir}/r_kraken_violin.out" \
        2> "${reports_dir}/r_kraken_violin.err"
