#!/bin/bash
#SBATCH --job-name=alpha
#SBATCH --output=/mnt/data/cushla/gutmeta/analysis/7a_alphadiversity/logs/sl_alphad_%j.out
#SBATCH --error=/mnt/data/cushla/gutmeta/analysis/7a_alphadiversity/logs/sl_alphad_%j.err
#SBATCH --nodes=1
#SBATCH --nodelist=alice
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=3-00:00:00

source activate py3

echo "SLURM_JOB_ID: " $SLURM_JOB_ID
echo "SLURM_JOB_NODELIST: " $SLURM_JOB_NODELIST
echo "SLURMTMPDIR: " $SLURMTMPDIR
echo "Python: " $(which python3)
echo "Python VERSION: " $(python3 --version 2>&1 | sed 's/^[^ ]* //')
echo "THREADS: " $SLURM_CPUS_PER_TASK

base_dir="/mnt/data/cushla/gutmeta/analysis"
bracken_dir="${base_dir}/5a_bracken_filtered"
alpha_dir="${base_dir}/7a_alphadiversity"
metrics=('BP' 'Sh' 'Si' 'ISi')

# alpha_diversity.py is Kraken Tools script

for infile in ${bracken_dir}/*.bracken.report.filtered.txt
do
	base=$(basename "${infile/.bracken.report.filtered.txt/}")
	echo ${base}
	for metric in "${metrics[@]}"
	do
		python3 alpha_diversity.py \
		-f ${infile} \
		-a ${metric} \
		> "${alpha_dir}/${base}.${metric}_alphadiversity.txt" \
		2> "${alpha_dir}/logs/py_alphad.err"
	done
done


