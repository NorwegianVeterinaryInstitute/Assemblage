#!/usr/bin/env Rscript

library(impoRt)
library(dplyr)
library(formattable)
library(tidyr)

completeness_report <- get_data(
  filepath = ".",
  pattern = "contig_names.txt",
  delim = "\t",
  col_names = FALSE
  ) %>%
  mutate(complete = ifelse(
    grepl("circular=true",X1), "circular", "non_circular"
  )) %>%
  group_by(ref, complete) %>%
  count() %>%
  ungroup() %>%
  pivot_wider(
    names_from = "complete",
    values_from = "n",
    values_fill = 0
  ) %>%
  mutate(
    total = circular + non_circular,
    percent = round(circular/total*100, 2),
    completeness = ifelse(percent == 100, "Complete", "Incomplete"),
    ref = sub("_contig_names.txt", "", ref)
  ) %>%
  select(-non_circular) %>%
  mutate(`Percent circularized contigs` = color_bar(color = "#80b1d3")(percent),
         `Completeness of genome` = color_tile("#fb8072","#b3de69")(completeness)) %>%
  rename(
    "Circularized contigs" = circular,
    "Total number of contigs" = total,
    "Sample ID" = ref
  ) %>%
  select(-c(percent, completeness))

write.table(
  completeness_report,
  "completeness_reports.txt",
  sep = "\t",
  quote = FALSE,
  row.names = FALSE
)
