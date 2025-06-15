#!/bin/bash
#SBATCH --job-name=strain
#SBATCH --output=/mnt/data/cushla/gutmeta/reports/analysis/logs/s_strain_agg%j.out
#SBATCH --error=/mnt/data/cushla/gutmeta/reports/analysis/logs/s_strain_agg%j.err
#SBATCH --nodes=1
#SBATCH --nodelist=fiorina
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=3-00:00:00

# set variables
base_dir="/mnt/data/cushla/gutmeta"
in_dir="${base_dir}/analysis/9a_strainGST"
out_dir="${base_dir}/reports/analysis"
out_file="strainGST_aggregate_results.tsv"

source activate py3

echo "SLURM_JOB_ID: " $SLURM_JOB_ID
echo "SLURM_JOB_NODELIST: " $SLURM_JOB_NODELIST
echo "SLURMTMPDIR: " $SLURMTMPDIR
echo "Python: " $(which python3)
echo "Python VERSION: " $(python3 --version 2>&1 | sed 's/^[^ ]* //')
echo "THREADS: " $SLURM_CPUS_PER_TASK
echo "ID: " $id

# parse_straingst (which is imported into python script) is StrainGE utils scripts

python3 strainGE_aggregate_tsv.py \
        -i ${in_dir} \
        -o ${out_dir} \
        -t "straingst_strains_aggregate.txv" \
        2> >(tee ${out_dir}/py_strain_agg.log >&2)
