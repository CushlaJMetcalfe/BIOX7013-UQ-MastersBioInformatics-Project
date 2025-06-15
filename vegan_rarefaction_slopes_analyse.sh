#!/bin/bash
#SBATCH --job-name=slope
#SBATCH --output=/mnt/data/cushla/gutmeta/analysis/6a_rarefaction/logs/s_rare_slope_%j.out
#SBATCH --error=/mnt/data/cushla/gutmeta/analysis/6a_rarefaction/logs/s_rare_slope_%j.err
#SBATCH --nodes=1
#SBATCH --nodelist=bob
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=3-00:00:00


# Set variables
script_dir="/home.roaming/s4662374/scripts"
in_dir="/mnt/data/cushla/gutmeta/analysis/6a_rarefaction"
report_dir="/mnt/data/cushla/gutmeta/reports/analysis"
tsv_file="vegan_rarefaction_av_slope_end_curve.tsv"
violin_plot="vegan_rarefaction_av_slope_end_curve_violin.pdf"
cutoff=e-13
samples_failed="vegan_rarefaction_failed_samples.txt"

source activate py3

echo "SLURM_JOB_ID: " $SLURM_JOB_ID
echo "SLURM_JOB_NODELIST: " $SLURM_JOB_NODELIST
echo "SLURMTMPDIR: " $SLURMTMPDIR
echo "PYTHON: " $(which python3)
echo "PYTHON VERSION: " $(python3 --version 2>&1 | sed 's/^[^ ]* //')

python3 \
	${script_dir}/vegan_rarefaction_slopes_analyse.py \
	-i ${in_dir} \
	-o ${report_dir} \
	-t "${report_dir}/${tsv_file}" \
	> "${report_dir}/logs/p_rare_slope.out" \
        2> "${report_dir}/logs/p_rare_slope.err"

conda deactivate

source activate r_vegan

echo "SLURM_JOB_ID: " $SLURM_JOB_ID
echo "SLURM_JOB_NODELIST: " $SLURM_JOB_NODELIST
echo "SLURMTMPDIR: " $SLURMTMPDIR
echo "R: " $(which R)
echo "R VERSION: " $(R --version 2>&1 | grep -oP '\d+\.\d+\.\d+')
echo "ID: " $id
echo "script dir" $script_dir

Rscript "${script_dir}/vegan_rarefaction_plot_av_slope_end_curve.R" \
        --input "${report_dir}/${tsv_file}" \
        --output_violin "${report_dir}/${violin_plot}" \
	--cutoff_failed "${cutoff}" \
	--output_failed "${report_dir}/${samples_failed}" \
        > "${report_dir}/logs/r_rare_plot.out" \
        2> "${report_dir}/logs/r_rare_plot.err"
