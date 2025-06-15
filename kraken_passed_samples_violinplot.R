#!/usr/bin/env Rscript

########################################################################################
# kraken_passed_samples_violinplot.R takes in the output from
# kraken_percent_classified.py and products violin plot (pdf) of
# the percent reads classified by kraken for all samples that
# passed the threshold specified by the user in 
# kraken_percent_classified_and_filter.sh
#
# the input files are:
# 1. file with sample name, percent reads classified by kraken
# 2. sample names for all samples that failed (% reads classified 
#    didn't pass threshold)
#
# the output file is:
# 1. pdf of violin plot of % reads classified by kraken for all
#    samples that passed threshold
# 
# Required Parameters:
#   -c, --input_csv_file.................csv file with sample name, percent reads 
#                                        classified by kraken
#   -t, --input_txt_file.................txt file with failed sample names
#   -p, --output_pdf.....................name of pdf file with violin plot
#
########################################################################################      

# Load required libraries

suppressPackageStartupMessages({
  library(optparse)
  library(tidyverse)
  library(scales)
})

option_list <- list(
  make_option(c("-c", "--input_csv_file"),
              type = "character",
              help = "Input csv file with sample name, percent classified by kraken"
  ),
  make_option(c("-t", "--input_txt_file"),
              type = "character",
              help = "Input txt file with sample names that failed"
  ),
  make_option(c("-p", "--output_pdf"),
              type = "character",
              help = "Filename for pdf file with violin plot"
  )
)

# Parse command line arguments
opt <- parse_args(OptionParser(option_list = option_list))



# Load files
kraken_percent_classified <- read_csv(opt$input_csv_file, 
                                      show_col_types = FALSE)

failed_samples <- read_csv(opt$input_txt_file, 
    col_names = TRUE, show_col_types = FALSE)
    
colnames(failed_samples) <-c('sample')

kraken_percent_classified  <- anti_join(kraken_percent_classified , failed_samples, by = "sample")

# Violin Plot

pdf(opt$output_pdf, width=8, height=6)

ggplot(kraken_percent_classified , aes(x = "", y = percent_classified)) +
  geom_violin(fill = "#365C8DFF", color = "#365C8DFF") +
  theme_minimal() +
  labs(title = "Distribution of Percent of Reads Classified by Kraken",
       x = "",
       y = "Percent Classified") +
  theme(plot.title = element_text(hjust=0.5))


dev.off()
