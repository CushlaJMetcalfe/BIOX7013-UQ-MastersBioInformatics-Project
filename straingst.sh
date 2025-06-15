#!/bin/bash
#SBATCH --job-name=straingst
#SBATCH --output=/mnt/data/cushla/gutmeta/analysis/9a_strainGST/logs/s_strain_%j.out
#SBATCH --error=/mnt/data/cushla/gutmeta/analysis/9a_strainGST/logs/s_strain_%j.err
#SBATCH --nodes=1
#SBATCH --nodelist=fiorina
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=3-00:00:00

# set variables
ecoli_dir=$1
gstrain_dir=$2
forward_reads=$3
reverse_reads=$4
id=$5
ecoli_db="/mnt/transient_data/dbs/strainGE/Nhu_list/Nhu_list_20241206_Ecoli_chr.hdf5"


source activate strainge

echo "SLURM_JOB_ID: " $SLURM_JOB_ID
echo "SLURM_JOB_NODELIST: " $SLURM_JOB_NODELIST
echo "SLURMTMPDIR: " $SLURMTMPDIR
echo "StrainGE: " $(which strainge)
echo "strainge VERSION: " $(strainge --version)
echo "THREADS: " $SLURM_CPUS_PER_TASK
echo "ID: " $id

# straingst kmerze is a StrainGE tool

straingst kmerize -k 23 \
        -o "${gstrain_dir}/${id}.strainGST.hdf5" \
        "${ecoli_dir}/${forward_reads}" \
        "${ecoli_dir}/${reverse_reads}" \
        2> >(tee "${gstrain_dir}/logs/${id}.kmer.log" >&2)

straingst run \
	-O \
	-o "${gstrain_dir}/${id}" \
	"${ecoli_db}" \
	"${gstrain_dir}/${id}.strainGST.hdf5" \
	2> >(tee "${gstrain_dir}/logs/${id}.run.log" >&2)
