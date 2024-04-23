#!/usr/bin/env Rscript

library(impoRt)
library(dplyr)

# Import and merge kraken2 reports
kraken_reports <- get_data(
  ".",
  pattern = "report",
  col_names = FALSE,
  convert = TRUE
  ) %>%
  rename("perc_fragments" = X1,
         "num_fragments_root" = X2,
         "num_fragments_direct" = X3,
         "rank_code" = X4,
         "NCBI_taxon" = X5,
         "scientific_name" = X6) %>%
  mutate_all(~trimws(., which = "both")) %>%
  mutate(ref = sub("\\.kr2\\.report", "", ref))

write.table(
  kraken_reports,
  "kraken_reports.txt",
  sep = "\t",
  quote = FALSE,
  row.names = FALSE
)
