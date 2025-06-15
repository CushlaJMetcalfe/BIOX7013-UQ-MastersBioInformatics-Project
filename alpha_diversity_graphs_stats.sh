#!/bin/bash
#SBATCH --job-name=alpha_graphs
#SBATCH --output=/mnt/data/cushla/gutmeta/analysis/7a_alphadiversity/logs/s_alpha_graphs_%j.out
#SBATCH --error=/mnt/data/cushla/gutmeta/analysis/7a_alphadiversity/logs/s_alpha_graphs_%j.err
#SBATCH --nodes=1
#SBATCH --nodelist=alice
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=3-00:00:00

# set variables
script_dir="/home.roaming/s4662374/scripts"
base_dir="/mnt/data/cushla/gutmeta"
kraken_dir="${base_dir}/analysis/4a_kraken"
alpha_dir="${base_dir}/analysis/7a_alphadiversity"
report_dir="${base_dir}/reports/analysis"
alpha_aggregate_file="alpha_diversity_aggregate.tsv"

# Create the directories if they do not exist
mkdir -p "${alpha_dir}/logs"
mkdir -p "${report_dir}/logs"

# python script to aggregate results from alpha_diversity.py
# into one file

source activate py3

echo "ALPHA_DIR: " ${alpha_dir}
echo "REPORT_DIR: " ${report_dir}
echo "SLURM_JOB_ID: " $SLURM_JOB_ID
echo "SLURM_JOB_NODELIST: " $SLURM_JOB_NODELIST
echo "SLURMTMPDIR: " $SLURMTMPDIR
echo "Python: " $(which python3)
echo "Python VERSION: " $(python3 --version 2>&1 | sed 's/^[^ ]* //')
echo "THREADS: " $SLURM_CPUS_PER_TASK

# need kraken dir for total squences in each sample

python3 alpha_diversity_aggregate.py \
                --kraken ${kraken_dir} \
                --alpha ${alpha_dir} \
                --output_file ${alpha_aggregate_file} \
		--output_dir ${report_dir} \
                > "${report_dir}/logs/py_alphad_agg.out" \
                2> "${report_dir}/logs/py_alphad_agg.err"


conda deactivate

# R script to output scatter and violin plots of alpha diversity metrics
# and file with mean and st dev of each alpha diversity metric

source activate r_vegan

echo "SLURM_JOB_ID: " $SLURM_JOB_ID
echo "SLURM_JOB_NODELIST: " $SLURM_JOB_NODELIST
echo "SLURMTMPDIR: " $SLURMTMPDIR
echo "R: " $(which R)
echo "R VERSION: " $(R --version 2>&1 | grep -oP '\d+\.\d+\.\d+')
echo "ID: " $id
echo "script dir" $script_dir

Rscript "${script_dir}/alpha_diversity_graphs_stats.R" \
        --input "${report_dir}/${alpha_aggregate_file}" \
        --output_scatter "${report_dir}/alpha_diversity_scatter.pdf"\
        --output_violin "${report_dir}/alpha_diversity_violin.pdf"\
	--output_metrics "${report_dir}/alpha_diversity_metrics.csv"\
	--output_statistics "${report_dir}/alpha_diversity_statistics.csv"\
        > "${report_dir}/logs/r_alpha_graphs.out" \
        2> "${report_dir}/logs/r_alpha_graphs.err"




