#!/usr/bin/env Rscript

#############################################################################################
# alpha_diversity_graphs_stats.R takes the output from alpha_diversity_aggregate.py
# and output plots and csv files with alpha diversity metrics and statistics
# 
# Input is: 
#  1. aggrgeate tsv files from alpha_diversity.py 
#   (Kraken Tools https://github.com/jenniferlu717/KrakenTools)
#
# Output:
#   1. scatter plots alpha diversity vs total sequences
#   2. violin + boxplot plot alpha diversity
#   3. csv file with alpha diversity metrics for each sample
#   4. csv file with statistics (mean, st dev) for each alpha diversity metric
#
# Required Parameters:
# 
#   -i, --input..............................alpha diversity aggregate report 
#                                            TSV file with alpha diversity metrics 
#                                            for each sample
#   -s, --output_scatter.....................file name for scatter plot (pdf)
#   -v, --output_violin......................file name for violin plot (pdf)
#   -m, --output_metrics.....................file name for alpha metrics for each sample (csv)
#   -o, --output_statistics..................file name for alpha metrics statistics (csv)
#
################################################################################################

# Load required libraries
suppressPackageStartupMessages({
  library(tidyverse)
  library(optparse)
})

option_list <- list(
  make_option(c("-i", "--input"),
              type = "character",
              help = "Input alpha diversity aggregate report TSV file with alpha diversity metrics for each sample"
  ),
  make_option(c("-s", "--output_scatter"),
              type = "character",
              help = "File name for scatter plot"
  ),
  make_option(c("-v", "--output_violin"),
              type = "character",
              help = "File name for violin plot"
  ),
  make_option(c("-m", "--output_metrics"),
              type = "character",
              help = "File name for CSV file of alpha metrics for each sample"
  ),
  make_option(c("-o", "--output_statistics"),
              type = "character",
              help = "File name for CSV file of alpha metrics statistics"
  )
)

# Parse command line arguments
opt <- parse_args(OptionParser(option_list = option_list))

# Read in Aggregate Alpha Diversity tsv file

alpha_diversity_data <- read_delim(opt$input,
    delim = "\t", escape_double = FALSE,
    trim_ws = TRUE, show_col_types = FALSE) %>%
  pivot_wider(names_from = metric,
              values_from = value,
              values_fill = 0) %>%
  filter(total_seqs > 1)

write.csv(alpha_diversity_data, opt$output_metrics, row.names=FALSE, quote=FALSE)
cat(sprintf("Saved Alpha Diversity Summary to: %s\n", opt$output_metrics))

alpha_plot_data <- alpha_diversity_data %>%
  pivot_longer(cols=!c(sample, total_seqs),
               names_to = 'metric') 

# Plot colours

viridis_colours <- c('#4AC16DFF','#1FA187FF','#277F8Eff', '#365C8DFF', '#46337EFF','#440154FF')

# 1. Scatter Plot alpha diversity vs total sequences

p<-alpha_plot_data %>%
  ggplot(aes(x=total_seqs, y=value, color = metric)) +
  geom_point(size=1) +
  geom_smooth () +
  scale_color_manual(values = viridis_colours) +
  facet_wrap(~metric, nrow=3, scales='free_y', 
             labeller = labeller(metric = c(
               "Sh" = "Shannon's",
               "Si" = "Simpsons",
               "ISi" = "Reciprocal of Simpsons",
               "BP" = "Berger Parker",
               "F" = "Fisher's"
             ))) +
  theme_minimal() +
  theme(axis.text.x = element_blank(),
        legend.position = "none",
        plot.title = element_text(hjust = 0.5)) +
  labs(x ="Total Number of Reads", y="", title = 'Alpha Diversity')

ggsave(opt$output_scatter, p, width = 8, height = 6)
cat(sprintf("Saved Alpha Diversity Scatter plot to: %s\n", opt$output_scatter))

# 2.Violin Plot Alpha Diversity

p<-alpha_plot_data %>%
  ggplot(aes(x = metric, y = value, fill = metric)) +
  geom_violin(color='transparent') +
  geom_boxplot(width=0.1, color="black", alpha=0.1, outlier.size=0.5) +
  scale_fill_manual(values = viridis_colours) +
  facet_wrap(~ metric, scales = "free_y", ncol = 2, 
             labeller = labeller(metric = c(
               "Sh" = "Shannon's",
               "Si" = "Simpsons",
               "ISi" = "Reciprocal of Simpsons",
               "BP" = "Berger Parker",
               "F" = "Fisher's"
             ))) +
  theme_minimal() +
  theme(axis.text.x = element_blank(),
        legend.position = "none",
        plot.title = element_text(hjust = 0.5)) +
  labs(x ="", y="value", title = 'Alpha Diversity')

ggsave(opt$output_violin, p, width = 8, height = 6)
cat(sprintf("Saved Alpha Diversity Violin plot to: %s\n", opt$output_violin))

# csv file with statistics (mean, st dev) for each alpha diversity metric

summary_statistics <- alpha_diversity_data %>%
  select(-sample) %>%
  summarise(across(everything(), list(mean = mean, 
                                      stdev =sd))) %>%
  pivot_longer(cols = everything(), 
               names_to = c("alpha_diversity_metric", "statistic"), 
               names_pattern = "(.*)_(mean|stdev)", 
               values_to = "value") %>%
  spread(key = statistic, value = value)

write.csv(summary_statistics, opt$output_statistics,  row.names=FALSE, quote=FALSE)
cat(sprintf("Saved Alpha Diversity Summary Statistics to: %s\n", opt$output_statistics)) 

