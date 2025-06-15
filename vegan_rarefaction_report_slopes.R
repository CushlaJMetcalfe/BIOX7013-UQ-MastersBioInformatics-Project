#!/usr/bin/env Rscript

########################################################################################
# vegan_rarefaction_report_slopes.R takes in the output from
# bracken species abundance estimates and outputs a rarefaction curve, 
# a tsv of rarefaction value at each depth and tsv of the slope of
# the rarefaction curve. The steps for each the rarefaction curve are 
# between 0 and the maximum number of sequences 
#
# the input file is:
# 1. bracken report tsv file with species abunance estimates
#
# the output files are:
# 1. pdf of rarefaction curve 
# 2. tsv of rarefaction values
# 3. tsv of slope of rarefaction curve
#
# Required Parameters:
#   -i, --input.................bracken tsv with species abundance estimates
#   -p, --output_pdf............name of pdf of rarefaction curve                             
#   -o, --output_tsv............name of tsv file with rarefaction values
#   -r, --output_slope..........name of tsv file with rarefaction slope values
#   -c, --cutoff................number of reads required to keep a species 
#
# This script is based on a script from Budi Permana
####################################################################################

# Load required libraries
suppressPackageStartupMessages({
    library(optparse)
    library(vegan)
    library(tidyverse)
    library(scales)
})

validateParams <- function(reads_cutoff) {
    # For now just check the reads_cutoff, we'll add more later, if needed
    if (reads_cutoff < 0) {
        stop("All numeric parameters must be positive")
    }
}

getAbundanceFromBracken <- function(file, reads_cutoff) {
    # Read and validate Bracken input file
    df <- read_tsv(file, show_col_types = FALSE)
    required_cols <- c("name", "new_est_reads")
    if (!all(required_cols %in% colnames(df))) {
        stop(sprintf(
            "Missing required columns: %s",
            paste(setdiff(required_cols, colnames(df)), collapse = ", ")
        ))
    }

    # Filter based on read cutoff
    filtered_df <- df %>%
        filter(new_est_reads >= reads_cutoff)

    # Transform data for abundance table
    # Create a single-row data frame where species are columns
    abundance_tab <- filtered_df %>%
        select(name, new_est_reads) %>%
        pivot_wider(
            names_from = name,
            values_from = new_est_reads,
            values_fill = 0
        ) %>%
        as.data.frame()

    # Extract the sample name
    sample_name <- tools::file_path_sans_ext(basename(file))
    sample_name <- sub("\\.bracken\\.report$", "", sample_name)
    
    # Set row name as the input file name (without path and extension)
    rownames(abundance_tab) <- sample_name

    return(abundance_tab)
}

runRarefaction<- function(abundance_table) {
  
  # Get total reads for the sample and step size
  # step size based on fraction of the data for 
  # slope analysis
  total_reads <- sum(abundance_table[1, ])
  s = seq(0, total_reads, by = (as.integer(total_reads/2500)))
  
  # Get sample ID from row name
  sample_id <- rownames(abundance_table)[1]
  
  # Perform rarefaction for each sample size
  results <- as.data.frame(rarefy(abundance_table, sample=s)) %>%
    mutate(sample=(sample_id)) %>%
    pivot_longer(-sample) %>%
    drop_na() %>% # where there is no sequencing info, i.e. past point of seq depth
    mutate(n_seqs = as.numeric(str_replace(name, "N",""))) %>%
    select(-name)
  
  
  return(results)
}

runRareSlope <- function(rarefy_data) {
  slope_data <- data.frame(sample = character(), n_seqs = numeric(), slope = numeric())
  
  # Ensure there are at least two rows to calculate the slope
  if (nrow(rarefy_data) > 1) {
    # Loop through the data to calculate slope between consecutive points
    for (i in 2:nrow(rarefy_data)) {
      # Calculate the slope using the formula: (y2 - y1) / (x2 - x1)
      slope <- (rarefy_data$value[i] - rarefy_data$value[i-1]) / 
        (rarefy_data$n_seqs[i] - rarefy_data$n_seqs[i-1])
      
      # Append result to slope_data
      slope_data <- rbind(slope_data, 
                          data.frame(sample = rarefy_data$sample[i], 
                                     n_seqs = rarefy_data$n_seqs[i], 
                                     slope = slope))
    }
    return(slope_data)
  } else {
    cat("Insufficient data to calculate slope.\n")
    return(slope_data)
  }
}

  

main <- function() {
    # Set up command line arguments
    option_list <- list(
        make_option(c("-i", "--input"),
            type = "character",
            help = "Input Bracken report TSV file with species abundance estimates"
        ),
        make_option(c("-o", "--output_tsv"),
            type = "character", default = "_rarefraction.tsv",
            help = "Output suffix for TSV output [default=%default]"
        ),
        make_option(c("-r", "--output_slope"),
                    type = "character", default = "_rareslope.tsv",
                    help = "Output suffix for TSV slope output [default=%default]"
        ),
        make_option(c("-p", "--output_pdf"),
            type = "character", default = "_rarefraction.pdf",
            help = "Output suffix for pdf output [default=%default]"
        ),
        make_option(c("-c", "--cutoff"),
            type = "integer", default = 10,
            help = "Minimum number of reads required to keep a species [default=%default]"
        )
    )

    # Parse command line arguments
    opt <- parse_args(OptionParser(option_list = option_list))

    # Validate input file exists
    if (!file.exists(opt$input)) {
        stop(sprintf("Input file not found: %s", opt$input))
    }

    # Validate parameters
    validateParams(opt$cutoff)

    # Process input file
    cat(sprintf("Processing input file: %s\n", opt$input))
    start_time <- Sys.time()
    abundance_tab <- getAbundanceFromBracken(opt$input, opt$cutoff)

    # Run rarefaction analysis
    rarefaction_data <- runRarefaction(abundance_tab)

    # Save results
    write_tsv(rarefaction_data, opt$output_tsv)
    cat(sprintf("Saved rarefaction results to: %s\n", opt$output_tsv))
    
    # Run slope of rarefaction analysis
    rareslope_data <-runRareSlope(rarefaction_data)
    
    # Save slope results
    write_tsv(rareslope_data, opt$output_slope)
    cat(sprintf("Saved rarefaction slope results to: %s\n", opt$output_slope))

    # Create rarefaction plot

    my_colors <-c("#440154", "#31688E", "#35B779", "#FDE725")
    random_color <- sample(my_colors,1)
    
    p <- rarefaction_data %>%
      ggplot(aes(x = n_seqs, y = value, )) +
      geom_line(color = random_color) +
      geom_point(size = 1, color = random_color ) +
      theme_minimal() +
      scale_x_continuous(
        trans = "identity",
        labels = scales::comma,
        breaks = pretty_breaks(n = 20)
      ) +
      scale_y_continuous(
        breaks = pretty_breaks(n=10)
      ) +
      theme(
        plot.title = element_text(hjust = 0.5, size = 14, face = "bold"),
        axis.title = element_text(size = 12),
        axis.text.x = element_text(size = 8, angle = 90),
        legend.position = 'none'
      ) +
      labs(
        title = paste("Rarefaction plot ", unique(rarefaction_data$sample)),
        x = "Sampled reads",
        y = "Species richness"
      )
    
    # Save plot
    ggsave(opt$output_pdf, p, width = 8, height = 6)
    cat(sprintf("Saved rarefaction plot to: %s\n", opt$output_pdf))

    cat(sprintf("\nCompleted in %s\n", format(Sys.time() - start_time)))
}

if (identical(environment(), globalenv())) {
    main()
}


