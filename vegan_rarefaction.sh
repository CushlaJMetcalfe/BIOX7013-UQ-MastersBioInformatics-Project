#!/bin/bash
#SBATCH --job-name=rare
#SBATCH --output=/mnt/data/cushla/gutmeta/analysis/6a_rarefaction_filtered/logs/rare_%j.out
#SBATCH --error=/mnt/data/cushla/gutmeta/analysis/6a_rarefaction_filtered/logs/rare_%j.err
#SBATCH --nodes=1
#SBATCH --nodelist=alice
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=3-00:00:00

# set variables
script_dir=$1
id=$2
in_dir=$3
out_dir=$4


# Activate environments
source activate r_vegan

echo "SLURM_JOB_ID: " $SLURM_JOB_ID
echo "SLURM_JOB_NODELIST: " $SLURM_JOB_NODELIST
echo "SLURMTMPDIR: " $SLURMTMPDIR
echo "R: " $(which R)
echo "R VERSION: " $(R --version 2>&1 | grep -oP '\d+\.\d+\.\d+')
echo "ID: " $id
echo "script dir" $script_dir


Rscript "${script_dir}/vegan_rarefaction_report_slopes.R" \
        --input "${in_dir}/${id}.bracken.report.filtered.txt" \
        --output_tsv "${out_dir}/${id}_rarefaction.tsv"\
        --output_pdf "${out_dir}/${id}_rarefaction.pdf"\
	--output_slope "${out_dir}/${id}_rareslope.tsv"\
        --cutoff 10 \
        2> >(tee "${out_dir}/${id}.Rrare.log" >&2)



