#!/usr/bin/env Rscript

########################################################################################
# vegan_rarefaction_plot_av_slope_end_curve.R takes in the output from
# vegan_rarefaction_slopes_analyse.py and outputs a violin plot of the slope of the
# last 10% of the rarefaction curve for all samples that passed the threshold
#
# Input is: 
#  1. single tsv file with aggregated slope of last 10% of the rarefaction curves  
#
# Output:
#  1. violin plot of the average slope of last 10% of the rarefaction curve
#  2. text file with failed sample names
#   	
# Required Parameters:
#
#   -i, --input.......................tsv file with aggregated slope of 
#                                     last 10% of the rarefaction curve
#   -v, --output_violin...............filename of violin plot (pdf)
#   -c, --cutoff_failed...............threshold for failed samples
#                                     value of average slope where samples are
#                                     considered to have failed
#   -f, --output_failed...............filename for failed samples (txt)
#
########################################################################################

# Load required libraries

suppressPackageStartupMessages({
  library(tidyr)
  library(dplyr)
  library(ggplot2)
  library(readr)
  library(optparse)
})

option_list <- list(
  make_option(c("-i", "--input"),
              type = "character",
              help = "Input Aggregated Rarefaction slopes TSV file"
  ),

  make_option(c("-v", "--output_violin"),
              type = "character",
              help = "Output suffix for violin plot pdf output"
  ),
  make_option(c("-c", "--cutoff_failed"),
              type = "numeric",
              help = "cutoff for failed samples"
  ),
  make_option(c("-f", "--output_failed"),
              type = "character",
              help = "Filename for failed samples"
  )
)


# Parse command line arguments
opt <- parse_args(OptionParser(option_list = option_list))

combined_avg_slopes <- read_delim(opt$input,
    delim = "\t", escape_double = FALSE,
    show_col_types = FALSE,
    trim_ws = TRUE)

failed_samples <- combined_avg_slopes %>%
  filter(avg_slope > opt$cutoff_failed) %>%
  select(sample)

write.table(failed_samples, opt$output_failed, quote = FALSE, row.names = FALSE, col.names = FALSE, sep = "\t")

combined_avg_slopes <- anti_join(combined_avg_slopes , failed_samples, by = "sample")

# Violin Plot

p <- combined_avg_slopes %>%
  ggplot(aes(x = factor(1), 
             y = avg_slope)) +
  geom_violin(trim = FALSE, fill='#46337EFF', alpha = 0.5) + # Violin plot
  geom_boxplot(width=0.1, color="black", alpha=0.8) +
  theme_minimal() +
  labs(title = "Average Slope of last 10% of Rarefaction Curve",
       y = "Average",
       x = "") +  # Remove x-axis label
  theme(axis.title.x = element_blank(), 
        axis.text.x = element_blank(),
        legend.position = 'none')

ggsave(opt$output_violin, p, width = 8, height = 6)
cat(sprintf("Saved Analysis of slope Rarefaction Curve Violin plot to: %s\n", opt$output_violin))


