#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)

rmarkdown::render(
    input  = 'report_kraken_data.Rmd',
    params = list(
        kraken_report = "kraken_reports.txt"
      )
)
