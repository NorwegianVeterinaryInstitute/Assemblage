#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
workflow <- args[1]
genome_size <- args[2]
species_name <- args[3]

# Generate rmarkdown report for the relevant track
if (workflow == "draft") {
    rmarkdown::render(
      input  = 'report_draft_assembly.Rmd',
      params = list(
        quast_report = "transposed_report.tsv",
        kraken_report = "kraken_reports.txt",
        coverage_report = "coverage_reports.txt",
        genome_size_val = genome_size,
        species_name = species_name
      )
    )
}
