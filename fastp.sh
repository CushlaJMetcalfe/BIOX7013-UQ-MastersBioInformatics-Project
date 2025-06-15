#!/bin/bash
#SBATCH --job-name=fastp
#SBATCH --output=/mnt/data/cushla/gutmeta/sequencing/passQC_reads/1a_fastp/logs/fastp_%j.out
#SBATCH --error=/mnt/data/cushla/gutmeta/sequencing/passQC_reads/1a_fastp/logs/fastp_%j.err
#SBATCH --nodes=1
#SBATCH --nodelist=alice
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=3-00:00:00

# Run fastp with chosen options for each file selected in fastp_batch.sh
# Quality trimming and filtering
# Quality control reports

# Set variables
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

# --length_required 80: default is 15
# --trim_poly_g: force poly g trimming
# --qualified_quality_phred 20: default is 15, quality >Q15, read is qualiifed

fastp \
        --in1 "${in_dir}/${forward}" --in2 "${in_dir}/${reverse}" \
        --out1 "${out_dir}/${id}_1.fastp.fastq.gz" \
        --out2 "${out_dir}/${id}_2.fastp.fastq.gz" \
        --json "${out_dir}/${id}.fastp.json" \
        --html "${out_dir}/${id}.fastp.html" \
        --thread ${threads} \
        --detect_adapter_for_pe \
	--length_required 80 \
	--trim_poly_g \
	--qualified_quality_phred 20 \ # default is 15, quality >Q15, read is qualiifed
        2> >(tee "${out_dir}/${id}.fastp.log" >&2)

