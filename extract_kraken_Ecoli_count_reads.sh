#!/bin/bash
#SBATCH --job-name=count_reads
#SBATCH --output=/mnt/data/cushla/gutmeta/reports/analysis/logs/count_ecoli%j.out
#SBATCH --error=/mnt/data/cushla/gutmeta/reports/analysis/logs/count_ecoli%j.err
#SBATCH --nodes=1
#SBATCH --nodelist=bob
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=10:00:00

# set variables
base_dir="/mnt/data/cushla/gutmeta"
fastq_dir="${base_dir}/analysis/8a_Ecoli_extract"
report_dir="${base_dir}/reports/analysis"
out_file="Ecoli_reads_counts.tsv"


# Create header for output file
echo -e "Sample_ID\tReads_Forward\tReads_Reverse\tTotal_Reads" > "$fastq_dir/$out_file"

# Find all unique sample names by looking at the forward reads
for forward_file in "$fastq_dir"/*_Ecolireads_1.fastq; do
    # Skip if no files match the pattern
    [ -e "$forward_file" ] || continue
    
    # Extract sample name from the filename
    sample_name=$(basename "$forward_file" | sed 's/_Ecolireads_1.fastq//')
    
    # Define the corresponding reverse file
    reverse_file="${forward_file/_1.fastq/_2.fastq}"
    
    # Check if the reverse file exists
    if [ -f "$reverse_file" ]; then
        # Count reads in forward file (each read has 4 lines in fastq format)
        if [[ "$forward_file" == *.gz ]]; then
            # For gzipped files
            forward_count=$(zcat "$forward_file" | wc -l | awk '{print $1/4}')
        else
            # For uncompressed files
            forward_count=$(wc -l < "$forward_file" | awk '{print $1/4}')
        fi
        
        # Count reads in reverse file
        if [[ "$reverse_file" == *.gz ]]; then
            # For gzipped files
            reverse_count=$(zcat "$reverse_file" | wc -l | awk '{print $1/4}')
        else
            # For uncompressed files
            reverse_count=$(wc -l < "$reverse_file" | awk '{print $1/4}')
        fi
        
        # Calculate total reads
        total_count=$(echo "$forward_count + $reverse_count" | bc)
        
        # Output results to file
        echo -e "${sample_name}\t${forward_count}\t${reverse_count}\t${total_count}" >> "$report_dir/$out_file"
        
        # Also print to console to see progress
        echo "Processed: ${sample_name} - ${total_count} total reads"
    else
        echo "Warning: Reverse file not found for sample ${sample_name}" >&2
    fi
done

echo "Read counts have been saved to $report_dir/$out_file"
