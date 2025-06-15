#!/bin/bash
#SBATCH --job-name=extract
#SBATCH --output=/mnt/data/cushla/gutmeta/analysis/8a_Ecoli_extract/logs/s_extract_%j.out
#SBATCH --error=/mnt/data/cushla/gutmeta/analysis/8a_Ecoli_extract/logs/s_extract_%j.err
#SBATCH --nodes=1
#SBATCH --nodelist=fiorina
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=3-00:00:00

# set variables
k_output=$1
k_report=$2
forward_reads=$3
reverse_reads=$4
id=$5
fastq_dir=$6
kraken_dir=$7
out_dir=$8
taxid=30462

source activate py3

echo "SLURM_JOB_ID: " $SLURM_JOB_ID
echo "SLURM_JOB_NODELIST: " $SLURM_JOB_NODELIST
echo "SLURMTMPDIR: " $SLURMTMPDIR
echo "Python: " $(which python3)
echo "Python VERSION: " $(python3 --version 2>&1 | sed 's/^[^ ]* //')
echo "THREADS: " $SLURM_CPUS_PER_TASK
echo "ID: " $id

# extract_kraken_reads.py is a Kraken Tools script

python3 extract_kraken_reads.py \
        -k ${kraken_dir}/${k_output} \
        -r ${kraken_dir}/${k_report} \
        -s1 ${fastq_dir}/${forward_reads} \
        -s2 ${fastq_dir}/${reverse_reads} \
        -o ${out_dir}/${id}_Ecolireads_1.fastq \
        -o2 ${out_dir}/${id}_Ecolireads_2.fastq \
        -t ${taxid} \
        --include-children \
        --fastq-output \
        2> >(tee ${out_dir}/logs/${id}.extract.log >&2)
