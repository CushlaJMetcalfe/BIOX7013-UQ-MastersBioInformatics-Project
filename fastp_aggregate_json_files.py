#!/usr/bin/env python

########################################################################################
# fastp_aggregate_json_files.py takes in all the fastp .json quality control files
# in a directory and outputs a pdf with 3 violin plots, 1. read quality, 
# 2. read length and total bases and 3. filtering results
# 
# kraken_percent_classified.py and products violin plot (pdf) of
# the percent reads classified by kraken for all samples that
# passed the threshold specified by the user in
# kraken_percent_classified_and_filter.sh
#
# the input files are:
# 1. all fastp .json quality control files in a directory 
#
# the output file is:
# 1. pdf of violin plot of % reads classified by kraken for all
#    samples that passed threshold
#
# Require parameters: 
#   -j, --json...............................directory with fastp .json files
#   -o, --out................................directory for all output files
#   -f, --file...............................filename for csv output summary file
#   -l, --failed.............................filename for txt failed ples file
#   -c, --cutoff.............................threshold for failed samples, 
#                                            number of reads in sample after quality 
#                                            trimming and filtering 
#
########################################################################################




import os
import glob
import pandas as pd
import json
from pathlib import Path
import argparse

# Parse command-line arguments
parser = argparse.ArgumentParser(description='Aggregate alpha diversity data')
parser.add_argument('--json', '-j', type=str, required=True, help='Directory for .json fastp files')
parser.add_argument('--out', '-o', type=str, required=True, help='Directory for output files')
parser.add_argument('--file', '-f', type=str, required=True, help='Filename for output summary file (.csv)')
parser.add_argument('--failed', '-l', type=str, required=True, help='Filename for failed samples (.txt)')
parser.add_argument('--cutoff', '-c', type=int, required=True, help='Cut off value for failed samples (number of reads)')

args = parser.parse_args()

# Specify the directories and files

json_folder_path = Path(args.json)
output_dir = Path(args.out)
output_summary_file = Path(args.file)
output_failed_file = Path(args.failed)
cut_off = args.cutoff

# Define a function to parse a single .fastp.log file
# Function to parse the JSON file
def parse_fastp_json(json_file_path):
    try:
        with open(json_file_path, 'r') as file:
            # Check if the file is empty
            file_content = file.read().strip()
            if not file_content:  # If file is empty
                print(f"Warning: The file {json_file_path} is empty.")
                return {}  # Return an empty dictionary or handle the empty file case as needed   
            
            # Load the JSON data into a Python dictionary
            data = json.loads(file_content)  # Using `loads()` directly instead of `load()` to catch errors
            
    except json.JSONDecodeError as e:
        print(f"Error decoding JSON in file: {json_file_path}")
        print(f"Error message: {e}")
        with open(json_file_path, 'r') as file:
            print(f"File content:\n{file.read()}")  # Print the raw content of the file to debug
        return {}
    except Exception as e:
        print(f"Unexpected error while reading {json_file_path}: {e}")
        return {}

    # Extract relevant sections
    summary = data.get("summary", {})
    before_filtering = summary.get("before_filtering", {})
    after_filtering = summary.get("after_filtering", {})
    filtering_result = data.get("filtering_result", {})
    duplication = data.get("duplication", {})
    adapter_cutting = data.get("adapter_cutting", {})
    
    # Extract the file prefix (e.g., SRR6468621 from SRR6468621.fastp.json)
    sample_name = os.path.basename(json_file_path).split('.')[0]

    # Create a dictionary to store extracted data
    parsed_data = {
        "Sample_Name": sample_name,
        "Fastp_Version": summary.get("fastp_version", "N/A"),
        "Sequencing_Type": summary.get("sequencing", "N/A"),
        
        # Before Filtering
        "BF_Total_Reads": before_filtering.get("total_reads"),
        "BF_Total_Bases": before_filtering.get("total_bases"),
        "BF_Q20_Bases": before_filtering.get("q20_bases"),
        "BF_Q30_Bases": before_filtering.get("q30_bases"),
        "BF_Q20_Rate": before_filtering.get("q20_rate"),
        "BF_Q30_Rate": before_filtering.get("q30_rate"),
        "BF_GC_Content": before_filtering.get("gc_content"),
        "BF_read1_mean_length": before_filtering.get("read1_mean_length"),
        "BF_read2_mean_length": before_filtering.get("read2_mean_length"), 
            
        # After Filtering
        "AF_Total_Reads": after_filtering.get("total_reads"),
        "AF_Total_Bases": after_filtering.get("total_bases"),
        "AF_Q20_Bases": after_filtering.get("q20_bases"),
        "AF_Q30_Bases": after_filtering.get("q30_bases"),
        "AF_Q20_Rate": after_filtering.get("q20_rate"),
        "AF_Q30_Rate": after_filtering.get("q30_rate"),
        "AF_GC_Content": after_filtering.get("gc_content"),
        "AF_read1_mean_length": after_filtering.get("read1_mean_length"),
        "AF_read2_mean_length": after_filtering.get("read2_mean_length"),
        
        # Filtering Results
        "Passed_Filter_Reads": filtering_result.get("passed_filter_reads"),
        "Low_Quality_Reads": filtering_result.get("low_quality_reads"),
        "Too_Many_N_Reads": filtering_result.get("too_many_N_reads"),
        "Too_Short_Reads": filtering_result.get("too_short_reads"),
        "Too_Long_Reads": filtering_result.get("too_long_reads"),
        
        # Duplication Rate
        "Duplication_Rate": duplication.get("rate"),
        
        # Adapter Cutting
        "Adapter_Trimmed_Reads": adapter_cutting.get("adapter_trimmed_reads"),
        "Adapter_Trimmed_Bases": adapter_cutting.get("adapter_trimmed_bases")
    }

    return parsed_data


#Function to process multiple JSON files
def process_multiple_json_files(json_dir, output_dir, output_summary, output_failed, Cut_off):
    # Find all JSON files in the folder
    json_files = glob.glob(f"{json_dir}/*.json")
    
    # Parse each file and collect the data
    all_data = []
    fastp_failed_samples=[]
    
    for json_file in json_files:
        # Skip files that don't have the .json extension (additional safeguard)
        if not json_file.endswith('.json'):
            print(f"Skipping non-JSON file: {json_file}")
            continue    
        
        print(f"Processing file: {json_file}")
        parsed_data = parse_fastp_json(json_file)
        
        # Skip empty or invalid JSON files (those returning empty dictionaries)
        if not parsed_data:
            print(f"Skipping empty or invalid file: {json_file}")
            continue   
        
        all_data.append(parsed_data)
        
        # Check if the AF_Total_Reads is less than cutoff
        if parsed_data.get("AF_Total_Reads", 0) < Cut_off:
            fastp_failed_samples.append(parsed_data["Sample_Name"])       
            
    # Convert the list of dictionaries to a DataFrame
    df = pd.DataFrame(all_data)
    
    # Save to a single CSV file
    df.to_csv(output_dir / output_summary, index=False)
    print(f"All data saved to {output_dir/output_summary}")
    
    # Save the failed samples to a text file (one per line)

    if fastp_failed_samples:
        print(f"Writing failed samples to: {output_dir / output_failed}")
        with open(output_dir / output_failed, 'w', newline='\n') as f:
            for sample in fastp_failed_samples:
                f.write(f"{sample}\n")
        print(f"Failed samples saved to {output_dir / output_failed}")
    else:
        print("No failed samples found, nothing to save.")
  

process_multiple_json_files(json_folder_path, output_dir, output_summary_file, output_failed_file, cut_off)

