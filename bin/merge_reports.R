#!/usr/bin/env Rscript

# Script for merging reports

# Load libraries
library(impoRt)
library(dplyr)
library(formattable)
library(kableExtra)
library(tidyr)
library(sparkline)

# COMPLETENESS
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
         `Completeness of genome` = cell_spec(
           completeness,
           color = "white",
           bold = TRUE,
           background = ifelse(completeness == "Complete", "#b3de69", "#fb8072"
          )
  )) %>%
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

# COVERAGE
func_paste <- function(x, collapse = ",") paste(unique(x[!is.na(x)]), collapse = collapse)

calc_cov <- function(df) {
  df %>%
    rename("reference" = X1,
           "pos" = X2,
           "reads" = X3) %>%
    mutate(reads_no_unmapped = ifelse(reads == 0, NA, reads),
           test = ifelse(reads == 0, 0, 1)) %>%
    group_by(reference) %>%
    summarise(reference = unique(reference),
              cov_perc = round(sum(test)/max(pos)*100, 2),
              mean_reads_per_base = round(mean(reads_no_unmapped, na.rm = TRUE), 2),
              median_reads_per_base = median(reads_no_unmapped, na.rm = TRUE),
              sd_reads_per_base = round(sd(reads_no_unmapped, na.rm = TRUE), 2)) %>%
    ungroup() %>%
    mutate(mean_cov = round(mean(mean_reads_per_base),2),
           median_cov = median(median_reads_per_base),
           mean_perc_cov = round(mean(cov_perc),2),
           Coverage = spk_chr(mean_reads_per_base, width = 180, height = 25))
}

coverage_reports <- get_data(
  ".",
  pattern = "il_genomecov.txt",
  col_names = FALSE,
  df = FALSE
) %>%
  lapply(., calc_cov) %>%
  bind_rows(.id = "sample") %>%
  group_by(sample) %>%
  summarise_all(list(func_paste)) %>%
  mutate(sample = sub("_il_genomecov.txt", "", sample),
         `Mean coverage` = color_bar(color = "#d9d9d9")(mean_cov),
         `Median coverage` = color_bar(color = "#ccebc5")(median_cov),
         `Mean percent coverage` = color_bar(color = "#fccde5")(mean_perc_cov)) %>%
  select(sample,
         `Mean coverage`,
         `Median coverage`,
         `Mean percent coverage`,
         Coverage) %>%
  rename("Assembly" = sample) %>%
  mutate(Coverage = gsub("\n", "", Coverage))

write.table(
  coverage_reports,
  "il_coverage_reports.txt",
  sep = "\t",
  quote = FALSE,
  row.names = FALSE
)


# NANOPORE COVERAGE
calc_cov_np <- function(df) {
  df %>%
    rename("reference" = X1,
           "pos" = X2,
           "reads" = X3) %>%
    mutate(reads_no_unmapped = ifelse(reads == 0, NA, reads),
           test = ifelse(reads == 0, 0, 1)) %>%
    group_by(reference) %>%
    summarise(reference = unique(reference),
              cov_perc = round(sum(test)/max(pos)*100, 2),
              mean_reads_per_base = round(mean(reads_no_unmapped, na.rm = TRUE), 2),
              mean_reads_per_base = ifelse(is.na(mean_reads_per_base), 0, mean_reads_per_base),
              median_reads_per_base = median(reads_no_unmapped, na.rm = TRUE),
              sd_reads_per_base = round(sd(reads_no_unmapped, na.rm = TRUE), 2)) %>%
    ungroup() %>%
    mutate(mean_cov = round(mean(mean_reads_per_base, na.rm = TRUE),2),
           median_cov = median(median_reads_per_base[which(!is.na(median_reads_per_base))]),
           mean_perc_cov = round(mean(cov_perc, na.rm = TRUE),2),
           Coverage = spk_chr(mean_reads_per_base, width = 180, height = 25))
}

coverage_reports <- get_data(
  ".",
  pattern = "np_genomecov.txt",
  col_names = FALSE,
  df = FALSE
) %>%
  lapply(., calc_cov_np) %>%
  bind_rows(.id = "sample") %>%
  group_by(sample) %>%
  summarise_all(list(func_paste)) %>%
  mutate(sample = sub("_np_genomecov.txt", "", sample),
         `Mean coverage` = color_bar(color = "#d9d9d9")(mean_cov),
         `Median coverage` = color_bar(color = "#ccebc5")(median_cov),
         `Mean percent coverage` = color_bar(color = "#fccde5")(mean_perc_cov)) %>%
  select(sample,
         `Mean coverage`,
         `Median coverage`,
         `Mean percent coverage`,
         Coverage) %>%
  rename("Assembly" = sample) %>%
  mutate(Coverage = gsub("\n", "", Coverage))

write.table(
  coverage_reports,
  "np_coverage_reports.txt",
  sep = "\t",
  quote = FALSE,
  row.names = FALSE
)

# QUAST
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
