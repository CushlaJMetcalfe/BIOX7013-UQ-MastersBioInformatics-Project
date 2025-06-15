#!/bin/bash
#SBATCH --job-name=kraken
#SBATCH --output=/mnt/data/cushla/gutmeta/analysis/4a_kraken/logs/kraken_%j.out
#SBATCH --error=/mnt/data/cushla/gutmeta/analysis/4a_kraken/logs/kraken_%j.err
#SBATCH --nodes=1
#SBATCH --nodelist=alice
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=3-00:00:00

# Run kraken2 with chosen options for each file selected in kraken_batch.sh
# Taxonomic classification of reads in each file

# set variables
forward=$1
reverse=$2
id=$3
in_dir=$4
out_dir=$5
threads=$SLURM_CPUS_PER_TASK
kraken_db="/dev/shm/Kraken_GTDB_R09-RS220/"

source activate kraken2

echo "SLURM_JOB_ID: " $SLURM_JOB_ID
echo "SLURM_JOB_NODELIST: " $SLURM_JOB_NODELIST
echo "SLURMTMPDIR: " $SLURMTMPDIR
echo "KRAKEN2: " $(which kraken2)
echo "KRAKEN2_VERSION: " $(kraken2 --version 2>&1 | sed -n 's/Kraken version \([0-9.]*\)/\1/p')
echo "THREADS: " $SLURM_CPUS_PER_TASK
echo "FORWARD: " $forward
echo "REVERSE: " $reverse
echo "ID: " $id

# --minimum-hit-groups: change to 3 from default of 2 for increased accuracy
# --report-minimizer-data: reports minimizer and distinct minimizer count information
# --gzip-compressed: input files are compressed with gzip
# --memory-mapping:  avoids loading database into RAM
# --paired: the filenames provided have paired-end reads
# --output: standard Kraken2 file
# --report: Kraken2 report file

kraken2 \
	--db "${kraken_db}" \
	--threads 4 \
	--report "${out_dir}/${id}_kraken2.report.txt" \
	--output "${out_dir}/${id}_kraken2.output.txt" \
	--gzip-compressed \
	--memory-mapping \
	--report-minimizer-data \
	--minimum-hit-groups 3 \
	--paired "${in_dir}/${id}_1.fastq.gz" "${in_dir}/${id}_2.fastq.gz" \
	2> >(tee "${out_dir}/${id}.kraken2.log" >&2)
