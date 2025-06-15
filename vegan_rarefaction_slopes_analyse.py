#!/usr/bin/env python

########################################################################################
# vegan_rarefaction_slopes_analyse.py takes in the output from
# vegan_rarefaction_report_slopes.R and calculates the average slope for the 10% of rows 
# in the vegan rarefaction slope tsv files (calculates the average slope of the last 10%
# of rarefaction curve)
#
# the input files are:
# 1.tsv file for each sample with the slope of the rarefaction curve at each point 
# 
# the output file is:
# 1. tsv summary file with all sample names and average slope of the last 10% of 
#    the rarefaction curve
#
# Required Parameters:
#   -i, --input_dir........................directory containing tsv files with
#                                          rarefaction slope for each sample
#   -o, --output_dir.......................output directory to write the output tsv file
#   -t, --output_tsv_file..................output file with the average slope of 
#                                          of the last 10% of rarefaction curve
#########################################################################################

import pandas as pd
import glob
import os
import math
import argparse

def process_files(input_dir, output_dir, output_file):
    # Ensure output directory exists
    os.makedirs(output_dir, exist_ok=True)
    
    # Get a list of all TSV files in the input directory
    files = glob.glob(os.path.join(input_dir, "*_rareslope.tsv"))
    
    results = []
    
    for file in files:
        try:
            df = pd.read_csv(file, sep="\t")
        except Exception as e:
            print(f"Error reading {file}: {e}")
            continue
        
        if 'slope' not in df.columns or 'sample' not in df.columns:
            print(f"Skipping {file}: missing required columns 'slope' or 'sample'")
            continue
        
        n_rows = len(df)
        last_n = math.ceil(0.1 * n_rows)
        avg_slope = df.tail(last_n)['slope'].mean()
        sample_name = df['sample'].iloc[0]
        
        results.append({"sample": sample_name, "avg_slope": avg_slope})
    
    # Convert results list to DataFrame
    results_df = pd.DataFrame(results)
    
    # Define the output file path
    file = output_file
    output_path = os.path.join(output_dir, file)
    
    # Write the DataFrame to TSV
    results_df.to_csv(output_path, sep="\t", index=False)
    print(f"Combined average slopes saved to {file}")

def main():
    parser = argparse.ArgumentParser(
        description="Calculate the average slope for the last 10% of rows from slope TSV files."
    )
    parser.add_argument("-i", "--input_dir", required=True,
                        help="Input directory containing slope tsv files")
    parser.add_argument("-o", "--output_dir", required=True,
                        help="Output directory to write the output tsv file")
    parser.add_argument("-t", "--output_tsv_file", required=True,
                        help="Output file with the average slope of last 10% of data")
    args = parser.parse_args()
    process_files(args.input_dir, args.output_dir, args.output_tsv_file)

if __name__ == '__main__':
    main()
