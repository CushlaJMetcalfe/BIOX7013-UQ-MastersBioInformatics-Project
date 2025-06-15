#!/bin/bash
#SBATCH --job-name=multiqc_filter
#SBATCH --output=/mnt/data/cushla/gutmeta/sequencing/passQC_reads/3a_filter_human/logs/s_mqc_%j.out
#SBATCH --error=/mnt/data/cushla/gutmeta/sequencing/passQC_reads/3a_filter_human/logs/s_mqc_%j.err
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --nodelist=bob
#SBATCH --cpus-per-task=1
#SBATCH --mem=1G
#SBATCH --time=00:30:00

# Run multiqc on fastp quality control output files
# Aggregates quality control reports

source activate multiqc

echo "SLURM_JOB_ID: " $SLURM_JOB_ID
echo "SLURM_JOB_NODELIST: " $SLURM_JOB_NODELIST
echo "SLURMTMPDIR: " $SLURMTMPDIR
echo "MULTIQC: " $(which multiqc)
echo "MULTIQC_VERSION: " $(multiqc --version 2>&1 | sed -e "s/multiqc, version //g")
echo "THREADS: " $SLURM_CPUS_PER_TASK

in_dir="/mnt/data/cushla/gutmeta/sequencing/passQC_reads/3a_filter_human"
out_dir="/mnt/data/cushla/gutmeta/reports/preprocessing"
filename="filter_human_multiqc"

multiqc \
        -f ${in_dir} \
        -o ${out_dir} \
        --filename ${filename} \
        2> >(tee "${out_dir}/multiqc.log" >&2)
