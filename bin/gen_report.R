#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)
workflow <- args[1]
genome_size <- args[2]

# Generate rmarkdown report for the relevant track
if (workflow == "draft") {
    rmarkdown::render(
      input  = 'report_draft_assembly.Rmd',
      params = list(
        quast_report = "transposed_report.tsv",
        kraken_report = "kraken_reports.txt",
        coverage_report = "coverage_reports.txt",
        genome_size_val = genome_size
      )
    )
}

if (workflow == "hybrid") {
    rmarkdown::render(
      input  = 'report_hybrid_assembly.Rmd',
      params = list(
        quast_report = "quast_comparison_report.txt",
	completeness_report = "completeness_reports.txt",
        coverage_report = "il_coverage_reports.txt",
	np_coverage_report = "np_coverage_reports.txt",
	kraken_report = "kraken_reports.txt"
      )
    )
}
