#!/usr/bin/env Rscript

library(impoRt)
library(dplyr)

quast_report <- get_data(
  filepath = ".",
  pattern = "transposed_report.tsv",
  delim = "\t",
  col_names = TRUE
) %>%
  select(-ref)

write.table(
  quast_report,
  "quast_comparison_report.txt",
  sep = "\t",
  quote = FALSE,
  row.names = FALSE
)
