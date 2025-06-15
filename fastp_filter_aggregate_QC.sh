#!/bin/bash
#SBATCH --job-name=json
#SBATCH --output=/mnt/data/cushla/gutmeta/reports/preprocessing/logs/fastp_qc_%j.log
#SBATCH --error=/mnt/data/cushla/gutmeta/reports/preprocessing/logs/fastp_qc_%j.err
#SBATCH --ntasks=1
#SBATCH --nodelist=alice
#SBATCH --cpus-per-task=1
#SBATCH --mem=16GB
#SBATCH --time=01:00:00

# set variables
script_dir="/home.roaming/s4662374/scripts"
json_dir="/mnt/data/cushla/gutmeta/sequencing/passQC_reads/3a_filter_human" # fastp qc json files
reports_dir="/mnt/data/cushla/gutmeta/reports/preprocessing" # output directory for files
fastp_aggregate_csv="filter_qc_aggregate.csv" # output from python json aggregate script
fastp_failed_txt="filter_qc_failed_samples.txt" # list of failed samples
cut_off=500000

source activate py3

# run python aggregate script for fastp trimming 
# and quality control
# output is a csv file of all fastp qc json files
# and a text file of failed samples (less than 500,000 reads)

echo "SLURM_JOB_ID: " $SLURM_JOB_ID
echo "SLURM_JOB_NODELIST: " $SLURM_JOB_NODELIST
echo "SLURMTMPDIR: " $SLURMTMPDIR
echo "Python: " $(which python3)
echo "Python VERSION: " $(python3 --version 2>&1 | sed 's/^[^ ]* //')


# run Python script
python ${script_dir}/fastp_aggregate_json_files.py \
	--json ${json_dir} \
	--out ${reports_dir} \
	--file ${fastp_aggregate_csv} \
	--failed ${fastp_failed_txt} \
	--cutoff ${cut_off} \
        > "${reports_dir}/logs/p_filter_json.out" \
        2> "${reports_dir}/logs/p_filter_json.err"


