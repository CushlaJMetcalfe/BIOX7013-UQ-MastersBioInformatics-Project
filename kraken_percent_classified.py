#!/usr/bin/env python3

######################################################################################
# kraken_percent_classified.py takes in all kraken logs files 
# in a directory and a % reads classified threshold and outputs 
# 1. a csv file with sample name, % classified
# 2. a txt file with all sample names that are below the selected
#    % reads classified threshold.
#
# Required Parameters:
#   -i, --dir-in..................Directory with kraken log files
#   -o, --dir-out.................Directory for output csv and txt file
#   -c, --cut_off.................Cut off set by user as % reads classified threshold.
#                                 Samples with % reads classified  under cut-off
#                                 will be considered failed samples
#   -f, --csv_file_out............output csv file with sample name, % reads classified
#   -t, --txt_file_out............text file with failed sample names
########################################################################################

import glob
import os
import csv
from pathlib import Path
import argparse
import re

# Parse command-line arguments
parser = argparse.ArgumentParser(description='Kraken Calculate percent unclassified reads')
parser.add_argument('--dir_in', '-i', type=str, required=True, help='Directory with .kraken2.log files')
parser.add_argument('--dir_out', '-o', type=str, required=True, help='Directory for output file')
parser.add_argument('--cut_off', '-c', type=int, required=True, help='Cut off for percentage classified')
parser.add_argument('--csv_file_out', '-f', type=str, required=True, help='Filename for csv output file with sample name, percent classified')
parser.add_argument('--txt_file_out', '-t', type=str, required=True, help='Filename for text output file with failed sample names only' )

args = parser.parse_args()

# Specify the directories and file
kraken_folder_path = Path(args.dir_in)
output_folder_path = Path(args.dir_out)
cut_off = args.cut_off
output_csv_file = args.csv_file_out
output_txt_file = args.txt_file_out

def main():
    # Find all files ending with *.kraken2.log in the specified directory
    files = glob.glob(f"{kraken_folder_path}/*.kraken2.log")
    
    if not files:
        print("No files matching *.kraken2.log were found.")
        return
    
    # List to store the results for each file
    csv_results = []
    txt_results = []
    
    for filepath in files:
        # Extract the base name (remove directories)
        base = os.path.basename(filepath)
        # Remove the specific suffix so that only the sample name remains.
        sample = base.replace(".kraken2.log", "")
        print(sample)
        
        # Open the log file and read lines
        with open(filepath, 'r') as file:
            lines = file.readlines()

            # Extract the classified percentage from the third line
            # This regex captures either a floating-point number or "-nan" inside parentheses.
            match = re.search(r'\(([-nan\d\.]+)%\)', lines[2])
            if match:
                percentage_str = match.group(1)
                # Convert "-nan" to "0.00" to represent no sequences classified.
                if percentage_str.lower() == '-nan':
                    percentage_classified = 0.00
                else:
                    percentage_classified = float(percentage_str)

                # Store the results
                csv_results.append([sample, f"{percentage_classified:.2f}"])
                if percentage_classified < cut_off:
                    txt_results.append(sample)
            else:
                print(f"No percentage found in {filepath}")

    # Write the csv_results to a CSV file
    output_csv_path = output_folder_path / output_csv_file
    with open(output_csv_path, "w", newline='') as csvfile:
         writer = csv.writer(csvfile)
         # Write header
         writer.writerow(["sample", "percent_classified"])
         # Write data rows
         writer.writerows(csv_results)
    
    print(f"Percent classified results written to {output_csv_path}")
    
    # Write the txt_results to a text file
    output_txt_path = output_folder_path / output_txt_file
    with open(output_txt_path, "w") as txtfile:
        # Always write the header line
        txtfile.write("sample\n")
        # Only write sample names if there are any failed samples
        for sample in txt_results:
            txtfile.write(sample + "\n")
    print(f"Failed samples names written to {output_txt_path}")              
    

if __name__ == '__main__':
    main()


