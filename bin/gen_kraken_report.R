#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
read_type <- if (length(args) >= 1) args[1] else "short_read"

rmarkdown::render(
    input  = 'report_kraken_data.Rmd',
    output_file = paste0("kraken_report_", read_type, ".html"),
    params = list(
        kraken_report = "kraken_reports.txt"
      )
)
