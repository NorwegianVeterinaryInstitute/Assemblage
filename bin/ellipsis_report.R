#!/usr/bin/env Rscript

library(impoRt)
library(dplyr)
library(readr)

resfinder_reports <- get_data(
  "C:/Users/vi1511/temp/assemblage/test_reports/",
  pattern = "resfinder_results.tsv",
  delim = "\t",
  col_names = TRUE,
  convert = TRUE
) %>%
  mutate(ref = sub("_resfinder_results.tsv", "", ref))

virfinder_reports <- get_data(
  "C:/Users/vi1511/temp/assemblage/test_reports/",
  pattern = "virulencefinder_results.tsv",
  delim = "\t",
  col_names = TRUE,
  convert = TRUE
) %>%
  mutate(ref = sub("_virulencefinder_results.tsv", "", ref))

plasmidfinder_reports <- get_data(
  "C:/Users/vi1511/temp/assemblage/test_reports/",
  pattern = "plasmidfinder_results.tsv",
  delim = "\t",
  col_names = TRUE,
  convert = TRUE
) %>%
  mutate(ref = sub("_plasmidfinder_results.tsv", "", ref))

mobsuite_reports <- get_data(
  "C:/Users/vi1511/temp/assemblage/test_reports/",
  pattern = "contig_report.txt",
  delim = "\t",
  col_names = TRUE,
  convert = TRUE
) %>%
  mutate(ref = sub(".contig_report.txt", "", ref))

reports <- mobsuite_reports %>%
  left_join(resfinder_reports, by = c("ref","contig_id" = "Contig")) %>%
  left_join(virfinder_reports, by = c("ref", "contig_id" = "Contig")) %>%
  left_join(plasmidfinder_reports, by = c("ref","contig_id" = "Contig"))

write_delim(
  reports,
  "ellipsis_report.tsv",
  delim = "\t"
)
