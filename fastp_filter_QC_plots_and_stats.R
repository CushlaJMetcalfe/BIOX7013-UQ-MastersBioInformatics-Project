#!/usr/bin/env Rscript

###############################################################################################
#
# fastp_filter_QC_plots_and_stats.R takes in results from fastp_aggregate_json_files.py
# from fastp and filtering human reads steps and outputs  
#
# Input:
#   
# Results from Python scripts that summarise .json files from fastp 
# and creates lists of failed files
#
#   1. csv file from aggregate of fastp json files
#   2. csv file from aggregate of fastp qc only of filtering human reads .json files
#   3. list of failed + cancelled fastp files
#   4. list of failed filter human reads files
#        
# Output files:
#   
#   1. csv file - summary mean and stdev after removing failed samples
#      
#   2. violin plots in one file (3 pages) after removing failed samples
#      a. ViolinPlot_fastp_Filter_Read_Quality.tiff
#         % reads Q>20 and Q>30 for 1. raw reads, 2. after fastp trim and 3. after filter human
#      b. ViolinPlot_fastp_QC1_Results.tiff
#         read length + total Gb 1. after fastp trim and 2. after filter human
#      c. ViolinPlot_fastp_QC2_Results.tiff
#         % reads pass 1. fastp trim and 2. filtering human
#         % adaptors removed fastp
#         % duplication fastp 
#         % GC fastp
# 
# Required Parameters:
#    -i, --input_fastp........................csv file with aggregate data from fastp json files 
#                                             after running fastp
#    -f, --input_filter.......................csv file with aggregate data from fastp json files 
#                                             after filtering human reads
#    -a, --input_fastp_failed.................txt file with list of failed fastp files
#    -b, --input_filter_failed................txt file with list of failed filter human reads files
#    -d, --output_dir.........................output directory for plots and csv files  
##################################################################################################

# Load required libraries
suppressPackageStartupMessages({
  library(optparse)
  library(tidyverse)
  library(scales)
})

Calculate_summary_statistics <- function(file) {
  # Select the relevant columns
  selected_columns <- file[, c("BF_Total_Reads", "BF_Total_Bases", "BF_Q20_Bases",
                               "BF_Q30_Bases", "BF_Q20_Rate", "BF_Q30_Rate",
                               "BF_GC_Content", "BF_read1_mean_length", "BF_read2_mean_length",
                               "AF_Total_Reads", "AF_Total_Bases", "AF_Q20_Bases",
                               "AF_Q30_Bases", "AF_Q20_Rate", "AF_Q30_Rate",
                               "AF_GC_Content", "AF_read1_mean_length", "AF_read2_mean_length",
                               "Passed_Filter_Reads", "Low_Quality_Reads", "Too_Many_N_Reads",
                               "Too_Short_Reads", "Too_Long_Reads", "Duplication_Rate",
                               "Adapter_Trimmed_Reads", "Adapter_Trimmed_Bases")]
  
  # Compute mean and standard deviation for each column
  table_results <- data.frame(
    Column = colnames(selected_columns),
    Mean = sapply(selected_columns, mean, na.rm = TRUE),
    StdDev = sapply(selected_columns, sd, na.rm = TRUE))
  
  return(table_results) 
}


option_list <- list(
  make_option(c("-i", "--input_fastp"),
              type = "character",
              help = "Input csv file with aggregate data from fastp json files after running fastp"
  ),
  make_option(c("-f", "--input_filter"),
              type = "character",
              help = "Input csv file with aggregate data from fastp json files after filtering human reads"
  ),
  make_option(c("-a", "--input_fastp_failed"),
              type = "character",
              help = "Input txt file with list of failed fastp files"
  ),
  make_option(c("-b", "--input_filter_failed"),
              type = "character",
              help = "Input txt file with list of failed filter human reads files"
  ),
  make_option(c("-d", "--output_dir"),
              type = "character",
              help = "Output directory for plots and csv files"
  )
)

# Parse command line arguments
opt <- parse_args(OptionParser(option_list = option_list))

# fastp results

## Read in results from python script summarising .json files from fastp

fastp_qc <- read_csv(opt$input_fastp, show_col_types = FALSE) %>%
  select(c(-Fastp_Version, -Sequencing_Type))


## Read in file with list of failed samples

fastp_failed <- read_csv(opt$input_fastp_failed, show_col_types = FALSE, col_names = FALSE)
colnames(fastp_failed) <-c('Sample_Name')

# filter human results

## Read in results from python script summarising .json files from fastp (qc only) after filtering human reads

human_filter_qc <-read_csv(opt$input_filter, show_col_types = FALSE) %>%
  select(c(-Fastp_Version, -Sequencing_Type))
  
## Read in file with list of failed samples

filter_failed <- read_csv(opt$input_filter_failed, show_col_types = FALSE, col_names = FALSE)
colnames(filter_failed) <- c('Sample_Name')

all_failed <- bind_rows(fastp_failed, filter_failed)

## remove failed samples from filtered results

### Save summmary tables with mean and st. dev.

fastp_qc_stats <- fastp_qc %>%
  anti_join(all_failed, by='Sample_Name') %>%
  Calculate_summary_statistics()

colnames(fastp_qc_stats) <- 
  paste("fastp", colnames(fastp_qc_stats),sep="_") 

human_filter_qc_stats <- human_filter_qc %>%
  anti_join(all_failed, by='Sample_Name') %>%
  Calculate_summary_statistics()

colnames(human_filter_qc_stats) <-
  paste("filter", colnames(human_filter_qc_stats), sep="_")

fastp_human_filter_QC_stats <- fastp_qc_stats%>%
  right_join(human_filter_qc_stats, by=c ("fastp_Column" = "filter_Column")) %>%
  rename(metric = fastp_Column)

write.csv(fastp_human_filter_QC_stats, file.path(opt$output_dir, "fastp_filter_qc_stats.csv"), row.names = FALSE)

### add prefix to colnames of files

colnames(fastp_qc) <- 
  paste("fastp", colnames(fastp_qc),sep="_") 

colnames(human_filter_qc) <-
  paste("filter", colnames(human_filter_qc), sep="_")

# remove Before Filtering values because they are the same as After Filtering values

human_filter_qc <- human_filter_qc %>%
  select(starts_with("filter_AF_"), filter_Sample_Name) 

## Join together
all_quality_control <- 
  right_join(fastp_qc, human_filter_qc, by=c("fastp_Sample_Name"="filter_Sample_Name"))

# remove failed samples

all_quality_control <- all_quality_control %>%
  anti_join(all_failed, by=c('fastp_Sample_Name' = 'Sample_Name'))

### Calculate variables

all_quality_control <- all_quality_control %>%
  mutate(fastp_AF_Total_Bases_Gb = 
           fastp_AF_Total_Bases/1000000000) %>% # 2nd plot - convert bases to Gb
  mutate(filter_AF_Total_Bases_Gb = 
           filter_AF_Total_Bases/1000000000) %>% # 2nd plot - convert bases to Gb
  mutate(fastp_Percent_GC_content = 
           fastp_BF_GC_Content*100) %>% # 3rd plot - convert rate to percentage
  mutate(fastp_Percent_duplication = 
           fastp_Duplication_Rate*100) %>% # 3rd plot - convert rate to percentage
  mutate(fastp_Percent_bases_adapters = 
           (fastp_Adapter_Trimmed_Bases /fastp_BF_Total_Bases)*100) %>% #3rd plot - calculate % bases are adapters 
  mutate(percent_reads_passed_fastp = 
           (fastp_AF_Total_Reads/fastp_BF_Total_Reads)*100) %>% # 3rd plot - calculate % reads passed fastp
  mutate(percent_reads_passed_filtering = 
           (filter_AF_Total_Reads/fastp_AF_Total_Reads)*100) # 3rd plot - calculate % reads passed filter human reads

#### convert na values to zero

all_quality_control <- all_quality_control %>% 
  mutate(across(everything(), ~ replace_na(.x, 0)))

# VIOLIN PLOTS

viridis_colours <- c('#94d840ff','#56C667ff','#29Af7fff', '#1F968bff', '#287d8eff','#326483ff')


### data for plots

data_plot1 <- all_quality_control %>%
  select(fastp_BF_Q20_Rate, 
         fastp_AF_Q20_Rate, 
         fastp_BF_Q30_Rate, 
         fastp_AF_Q30_Rate,
         filter_AF_Q20_Rate,
         filter_AF_Q30_Rate) %>%
  pivot_longer(cols = everything(), 
               names_to = "Variable", 
               values_to = "Value") %>%
  mutate(Value = Value *100) %>%
  # Create a grouping variable based on the presence of "Q20" or "Q30" in the variable name
  mutate(
    QualityGroup = if_else(str_detect(Variable, "Q20"), ">Q20", ">Q30"),
    Variable = fct_relevel(Variable,
                           "filter_AF_Q30_Rate",
                           "fastp_AF_Q30_Rate",
                           "fastp_BF_Q30_Rate",
                           "filter_AF_Q20_Rate",
                           "fastp_AF_Q20_Rate",
                           "fastp_BF_Q20_Rate")
  ) 

data_plot2 <- all_quality_control %>%
  select(
    fastp_AF_read1_mean_length,
    filter_AF_read1_mean_length,
    fastp_AF_read2_mean_length,
    filter_AF_read2_mean_length,
    fastp_AF_Total_Bases_Gb,
    filter_AF_Total_Bases_Gb
  ) %>%
  pivot_longer(cols = everything(), 
               names_to = "Variable", 
               values_to = "Value") %>%
  mutate(Variable = fct_relevel(Variable,
                                "fastp_AF_read1_mean_length",
                                "filter_AF_read1_mean_length",
                                "fastp_AF_read2_mean_length",
                                "filter_AF_read2_mean_length",
                                "fastp_AF_Total_Bases_Gb",
                                "filter_AF_Total_Bases_Gb"))

data_plot3 <- all_quality_control %>%
  select(
    fastp_Percent_GC_content, 
    fastp_Percent_duplication, 
    fastp_Percent_bases_adapters, 
    percent_reads_passed_fastp,
    percent_reads_passed_filtering
  ) %>%
  pivot_longer(cols = everything(), 
               names_to = "Variable", 
               values_to = "Value")

### Plots

pdf(file.path(opt$output_dir, "fastp_filter_qc_violin_plots.pdf"), width=8, height=6)

ggplot(data_plot1, aes(x = Variable, y = Value, fill = Variable, color = Variable)) +
  geom_violin(width = 0.8, linewidth = 0.5) +
  geom_boxplot(width=0.05, color="black", alpha=0.4) +
  scale_y_continuous(limits = c(0, 100), breaks = seq(0, 100, by = 10),
                     labels = label_number(accuracy = 1)) +
  # Facet by QualityGroup so that the y axis has grouping labels
  facet_grid(QualityGroup ~ ., scales = "free_y", space = "free_y") +
  coord_flip() +
  scale_x_discrete(labels = c("fastp_AF_Q30_Rate" = "After Fastp Trimming & Filtering",
                              "fastp_BF_Q30_Rate" = "Before Fastp Trimming & Filtering",
                              "fastp_AF_Q20_Rate" = "After Fastp Trimming & Filtering",
                              "fastp_BF_Q20_Rate" = "Before Fastp Trimming & Filtering",
                              "filter_AF_Q20_Rate" = "After Filtering human reads",
                              "filter_AF_Q30_Rate" = "After Filtering human reads")) +
  scale_color_manual(values = viridis_colours) +
  scale_fill_manual(values = viridis_colours) +
  theme_minimal() +
  theme(
    plot.title = element_text(hjust = 0.5),
    legend.position = "none",
    # Optionally adjust the facet strip text (angle, size, etc.)
    strip.text.y = element_text(angle = 0)
  ) +
  ggtitle("Read Quality") +
  xlab("") +
  ylab("% of bases in reads")

ggplot(data_plot2, aes(x="", y=Value, fill=Variable, color=Variable)) +
  geom_violin()+
  geom_boxplot(width=0.05, color="black", alpha=0.4) +
  facet_wrap(~ Variable, scales = "free_x", ncol = 1, labeller=labeller(Variable = 
                      c("fastp_AF_read1_mean_length" = "Read 1 mean length after Fastp Trimming & Filtering",                         
                        "fastp_AF_read2_mean_length" = "Read 2 mean length after Fastp Trimming & Filtering",
                        "fastp_AF_Total_Bases_Gb" = "Total bases (Gb) after Fastp Trimming & Filtering",
                        "filter_AF_read1_mean_length" = "Read 1 mean length after Filtering Human Reads ",
                        "filter_AF_read2_mean_length" = "Read 2 mean length after Filtering Human Reads",
                        "filter_AF_Total_Bases_Gb" = "Total bases (Gb) after Filtering Human Reds"
                    
                        ))) +
  coord_flip() +
  scale_color_manual(values = viridis_colours) +
  scale_fill_manual(values = viridis_colours) +
  scale_y_continuous(breaks = pretty_breaks(n=20)) +
  theme_minimal() +
  theme(
      plot.title = element_text(hjust=0.5),
      legend.position="none",
      strip.text = element_text(angle = 0, hjust = 0, size =9),# Position facet labels along the axis
        ) +
 # Rotate x-axis labels if needed
  ggtitle("Filtering Results 1") +
  xlab("")

ggplot(data_plot3, aes(x="", y=Value, fill=Variable, color=Variable)) +
    geom_violin() +
    geom_boxplot(width=0.05, color="black", alpha=0.4) +
    facet_wrap(~ Variable, scales = "free_x", ncol = 1, labeller=labeller(Variable = 
                      c(
                        "fastp_Percent_GC_content" = "% GC Before Fastp", 
                        "fastp_Percent_duplication" = "% Duplication Before Fastp", 
                        "fastp_Percent_bases_adapters" = "% Adapters Before Fastp", 
                        "percent_reads_passed_fastp" = "% Reads passed Fastp Trimming and Filtering",
                        "percent_reads_passed_filtering" = "% Reads passed Filtering Human Reads"
                        ))) +
    coord_flip() +
    scale_color_manual(values = viridis_colours) +
    scale_fill_manual(values = viridis_colours) +
    scale_y_continuous(breaks = pretty_breaks(n=20)) +
    theme_minimal() +
    theme(
      plot.title = element_text(hjust=0.5),
      legend.position="none",
      strip.text = element_text(angle = 0, hjust = 0, size =10),# Position facet labels along the axis
       ) +
    ggtitle("Filtering Results 2") +
    xlab("")

dev.off()
