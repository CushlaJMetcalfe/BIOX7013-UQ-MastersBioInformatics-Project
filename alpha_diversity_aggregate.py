#!/usr/bin/env python

########################################################################################
# alpha_diversity_aggregate.py takes in the outputs from alpha_diversity.py 
# (Kraken tool https://github.com/jenniferlu717/KrakenTools/tree/master/DiversityTools)
# and the number of reads classified by Kraken for each sample and aggregates 
# the results into a single tsv file. 
#
# the input files are:
# 1. kraken log files with percent reads classified by Kraken 
# 2. alpha diversity files for each sample for each metric chosen in alpha_diversity.sh
#
# the output file is:
# 1. aggregate tsv file with sample, value for each alpha diversity metric and % reads
#    classified
#
# Required Parameters:
#   -k, --kraken...................................directory with Kraken log files 
#   -a, --alpha....................................input directory with individual alpha diversity files
#   -d, --output_dir...............................output directory for output file 
#   -o, --ouptut_file..............................file name (tsv) with alpha diversity aggregates
#                                                  for all samples in input directory
#
########################################################################################################




import os
import pandas as pd
from pathlib import Path
import argparse

# Parse command-line arguments
parser = argparse.ArgumentParser(description='Aggregate alpha diversity data.')
parser.add_argument('--kraken', '-k', type=str, required=True, help='Directory with Kraken log files')
parser.add_argument('--alpha', '-a', type=str, required=True, help='Directory with Alpha diversity files')
parser.add_argument('--output_dir', '-d', type=str, required=True, help='Output Directory alpha diversity aggregate')
parser.add_argument('--output_file', '-o', type=str, required=True, help='Output file name alpha diversity aggregates')

args = parser.parse_args()

#Specify the directories
base_dir = Path(__file__).resolve().parent.parent
kraken_dir = Path(args.kraken)
alpha_dir = Path(args.alpha)
output_dir = Path(args.output_dir)
output_file = Path(args.output_file)

# Create empty dataframe with column names
combined_alpha = pd.DataFrame(columns=['sample', 'metric', 'value'])
 
# Read in alpha diversity information and add to dataframe
for filename in os.listdir(alpha_dir):
    if filename.endswith('_alphadiversity.txt'):
        file_path = os.path.join(alpha_dir, filename)
        with open(file_path, 'r') as file:
            sample_name = filename.split('.')[0]
            metric_name = filename.split('.')[1].split('_')[0]
            alpha_value = file.read().split(':')[1].rstrip()
            new_row = [sample_name, metric_name, alpha_value]
            combined_alpha.loc[len(combined_alpha)] = new_row

print (combined_alpha.head(10))
     
#Read in kraken log files and add total seqs to dataframe
for filename in os.listdir(kraken_dir):
    if filename.endswith('.log'):
        file_path = os.path.join(kraken_dir, filename)
        with open(file_path, 'r') as file:
            sample_name = filename.split('.')[0]
            total_seqs = file.readlines()[1] .split(' ')[0]
            new_row = [sample_name, 'total_seqs', total_seqs]
            combined_alpha.loc[len(combined_alpha)] = new_row
                       
combined_alpha.to_csv(f'{output_dir}/{output_file}', sep='\t', index=False)
        
# print(f"Saved aggregated alpha diversity data to: {output_dir}/{output_file}")            
    
