#!/usr/bin/env Rscript

# Script for merging reports

# Load libraries
library(impoRt)
library(dplyr)
library(tibble)
library(formattable)
library(kableExtra)
library(tidyr)
library(sparkline)

# Helper function to ensure sample column is always created
to_named_list <- function(x) {
  if (is.data.frame(x)) {
    # Single-file case can come back as a data frame
    if ("ref" %in% names(x)) {
      return(split(x, x$ref))
    }
    return(list(sample_1 = x))
  }

  if (!is.list(x)) {
    return(list(sample_1 = as.data.frame(x)))
  }

  # If list has no names, derive from each element's ref if present
  if (is.null(names(x)) || any(names(x) == "")) {
    names(x) <- vapply(seq_along(x), function(i) {
      xi <- x[[i]]
      if (is.data.frame(xi) && "ref" %in% names(xi)) {
        as.character(xi$ref[1])
      } else {
        paste0("sample_", i)
      }
    }, character(1))
  }

  x
}

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
  to_named_list() %>%
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
  to_named_list() %>%
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
