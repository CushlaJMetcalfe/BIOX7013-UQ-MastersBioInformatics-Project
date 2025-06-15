#!/bin/bash
#SBATCH --job-name=QCPLot
#SBATCH --output=/mnt/data/cushla/gutmeta/reports/preprocessing/logs/QC_%j.out
#SBATCH --error=/mnt/data/cushla/gutmeta/reports/preprocessing/logs/QC_%j.err
#SBATCH --nodes=1
#SBATCH --nodelist=alice
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=3-00:00:00

# set variables
script_dir="/home.roaming/s4662374/scripts"
dir="/mnt/data/cushla/gutmeta/reports/preprocessing"
fastp_qc="fastp_qc_aggregate.csv"
filter_qc="filter_human_qc_aggregate.csv"
fastp_failed="fastp_cancelled_failed_samples.txt"
filter_failed="filter_qc_failed.samples.txt"

# Activate environments
source activate r_vegan

echo "SLURM_JOB_ID: " $SLURM_JOB_ID
echo "SLURM_JOB_NODELIST: " $SLURM_JOB_NODELIST
echo "SLURMTMPDIR: " $SLURMTMPDIR
echo "R: " $(which R)
echo "R VERSION: " $(R --version 2>&1 | grep -oP '\d+\.\d+\.\d+')
echo "ID: " $id
echo "script dir" $script_dir


Rscript "${script_dir}/fastp_filter_QC_plots_and_stats.R" \
        --input_fastp "${dir}/${fastp_qc}" \
        --input_filter "${dir}/${filter_qc}" \
        --input_fastp_failed "${dir}/${fastp_failed}"\
	--input_filter_failed "${dir}/${filter_failed}"\
        --output_dir "${dir}" \
        2> >(tee "${dir}/logs/r_fastp_filter_QC.log" >&2)



