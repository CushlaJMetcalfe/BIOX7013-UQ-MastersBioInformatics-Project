#!/bin/bash
#SBATCH --job-name=filter_human
#SBATCH --output=/mnt/data/cushla/gutmeta/sequencing/passQC_reads/3a_filter_human/logs/filter_%j.out
#SBATCH --error=/mnt/data/cushla/gutmeta/sequencing/passQC_reads/3a_filter_human/logs/filter_%j.err
#SBATCH --nodes=1
#SBATCH --nodelist=bob
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=3-00:00:00

# filter human reads from .gz files selected in filter_human_batch.sh

# set variables
forward=$1
reverse=$2
id=$3
in_dir=$4
out_dir=$5
threads=$SLURM_CPUS_PER_TASK
human_db="/mnt/transient_data/dbs/GRCh38.p14/GCF_000001405.40/GCF_000001405.40_GRCh38.p14_genomic.fna"

# Activate environments
source activate bwa2

echo "SLURM_JOB_ID: " $SLURM_JOB_ID
echo "SLURM_JOB_NODELIST: " $SLURM_JOB_NODELIST
echo "BWA_MEM: " $(which bwa-mem2)
echo "BWA_MEM VERSION: " $(bwa-mem2 version 2>&1 | awk 'END{print $1}')
echo "SAMTOOLS: " $(which samtools)
echo "SAMTOOLS VERSION: " $(samtools --version-only 2>&1)
echo "THREADS: " $SLURM_CPUS_PER_TASK
echo "FORWARD: " $forward
echo "REVERSE: " $reverse
echo "ID: " $id


# samtools view -bS: output BAM file from SAM file, -f 4: unmapped reads
# samtools sort -n: sort by name so that read-pairs remain together
# samtools fastq -n: leave read names as they are

bwa-mem2 mem \
        -t ${threads} \
        "${human_db}" \
        "${in_dir}/${forward}" \
        "${in_dir}/${reverse}" \
        | samtools view -f 4 -bS \
	| samtools sort -n \
	| samtools fastq -1 "${out_dir}/${id}_1.filter.fastq.gz" -2 "${out_dir}/${id}_2.filter.fastq.gz" -n \
	2> >(tee "${out_dir}/${id}.filter.log" >&2)
