#!/usr/bin/env Rscript

library(impoRt)
library(dplyr)
library(formattable)
library(sparkline)

# Import and merge coverage reports
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
  pattern = "genomecov.txt",
  col_names = FALSE,
  df = FALSE
) %>%
  lapply(., calc_cov) %>%
  bind_rows(.id = "sample") %>%
  group_by(sample) %>%
  summarise_all(list(func_paste)) %>%
  mutate(sample = sub("_genomecov.txt", "", sample),
         `Mean coverage` = color_bar(color = "#d9d9d9")(mean_cov),
         `Median coverage` = color_bar(color = "#ccebc5")(median_cov),
         `Mean percent coverage` = color_bar(color = "#fccde5")(mean_perc_cov)) %>%
  select(sample,
         `Mean coverage`,
         `Median coverage`,
         `Mean percent coverage`,
         Coverage) %>%
  rename("Assembly" = sample)

write.table(
  coverage_reports,
  "coverage_reports.txt",
  sep = "\t",
  quote = FALSE,
  row.names = FALSE
)
