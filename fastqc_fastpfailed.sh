#!/bin/bash
#SBATCH --job-name=fastqc
#SBATCH --output=/mnt/data/cushla/gutmeta/sequencing/passQC_reads/1a_rerun_fastqc/logs/s_fastqc_%j.out
#SBATCH --error=/mnt/data/cushla/gutmeta/sequencing/passQC_reads/1a_rerun_fastqc/logs/s_fastqc_%j.err
#SBATCH --nodes=1
#SBATCH --nodelist=alice
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=3-00:00:00

# Run fastqc for each file selected in fastqc_batch_fastpfailed.sh
# Quality control tool 

# set variables
forward=$1
reverse=$2
id=$3
in_dir=$4
out_dir=$5
threads=$SLURM_CPUS_PER_TASK

source activate fastqc

echo "SLURM_JOB_ID: " $SLURM_JOB_ID
echo "SLURM_JOB_NODELIST: " $SLURM_JOB_NODELIST
echo "SLURMTMPDIR: " $SLURMTMPDIR
echo "FASTQC: " $(which fastqc)
echo "FASTP_VERSION: " $(fastqc --version 2>&1 | sed -e "s/FastQC //g")
echo "THREADS: " $SLURM_CPUS_PER_TASK
echo "FORWARD: ${in_dir}/${forward}"
echo "REVERSE: ${in_dir}/${reverse}"
echo "OUT DIR: ${out_dir}/"
echo "ID: " $id

fastqc \
        -t ${threads} \
	-o "${out_dir}/" \
	"${in_dir}/${forward}" \
	"${in_dir}/${reverse}" \
	2> >(tee "${out_dir}/${id}.fastp.log" >&2)
