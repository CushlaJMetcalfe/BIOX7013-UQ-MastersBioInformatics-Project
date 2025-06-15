#!/bin/bash
#SBATCH --job-name=bracken
#SBATCH --output=/mnt/data/cushla/gutmeta/analysis/5a_bracken/logs/bracken_%j.out
#SBATCH --error=/mnt/data/cushla/gutmeta/analysis/5a_bracken/logs/bracken_%j.err
#SBATCH --nodes=1
#SBATCH --nodelist=alice
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=3-00:00:00

# Run braken on samples selected in bracken_batch.sh
# Computes the abundance of species from kraken2.reports

# set variables
id=$1
in_dir=$2
out_dir=$3
threads=$SLURM_CPUS_PER_TASK
kraken_db="/dev/shm/Kraken_GTDB_R09-RS220/"

source activate bracken

echo "SLURM_JOB_ID: " $SLURM_JOB_ID
echo "SLURM_JOB_NODELIST: " $SLURM_JOB_NODELIST
echo "SLURMTMPDIR: " $SLURMTMPDIR
echo "BRACKEN: " $(which bracken)
echo "BRACKEN_VERSION: " $(bracken -v 2>&1 | sed -n 's/Bracken v\([0-9.]*\)/\1/p')
echo "THREADS: " $SLURM_CPUS_PER_TASK
echo "ID: " $id

# -r 100: average read length in dataset is 100bp
# -l S: set abundance level estimation to species
# -t 10: require 10 reads before abundance estimation, removes noise from low-abundance species

bracken \
	-d "$kraken_db" \
	-i "${in_dir}/${id}_kraken2.report.txt" \
	-r 100 \
	-l S \
	-t 10 \
	-o "${out_dir}/${id}.bracken.report.txt" \
	-w "${out_dir}/${id}.bracken.breport.txt" \
	2> >(tee "${out_dir}/${id}.bracken.log" >&2)
