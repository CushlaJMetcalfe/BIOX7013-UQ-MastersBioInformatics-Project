#!/bin/bash
#SBATCH --job-name=fastpqc
#SBATCH --output=/mnt/data/cushla/gutmeta/sequencing/passQC_reads/3a_qc_filter_human/logs/fastp_%j.out
#SBATCH --error=/mnt/data/cushla/gutmeta/sequencing/passQC_reads/3a_qc_filter_human/logs/fastp_%j.err
#SBATCH --nodes=1
#SBATCH --nodelist=bob
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=3-00:00:00

# Run fastp on files selected in fastp_qc_batch.sh
# Set options so that all trimming and filtering options are disabled
# Output is quality control reports only

# set variables
forward=$1
reverse=$2
id=$3
in_dir=$4
out_dir=$5
threads=$SLURM_CPUS_PER_TASK

source activate fastp

echo "SLURM_JOB_ID: " $SLURM_JOB_ID
echo "SLURM_JOB_NODELIST: " $SLURM_JOB_NODELIST
echo "SLURMTMPDIR: " $SLURMTMPDIR
echo "FASTP: " $(which fastp)
echo "FASTP_VERSION: " $(fastp --version 2>&1 | sed -e "s/fastp //g")
echo "THREADS: " $SLURM_CPUS_PER_TASK
echo "FORWARD: " $forward
echo "REVERSE: " $reverse
echo "ID: " $id

# --disable_adapter_trimming: Prevents adapter trimming
# --disable_quality_filtering: Disables quality filtering
# --disable_length_filtering: Disables length filtering

fastp \
        --in1 "${in_dir}/${forward}" --in2 "${in_dir}/${reverse}" \
        --out1 /dev/null \
        --out2 >(cat > /dev/null) \
        --json "${out_dir}/${id}.filter.fastp_qc.json" \
        --html "${out_dir}/${id}.filter.fastp_qc.html" \
        --thread ${threads} \
        --disable_adapter_trimming \
	--disable_quality_filtering \
	--disable_length_filtering \
	2> >(tee "${out_dir}/${id}.filter.fastp_qc.log" >&2)
