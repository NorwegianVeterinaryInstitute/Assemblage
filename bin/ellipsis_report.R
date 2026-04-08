#!/usr/bin/env Rscript

library(impoRt)
library(dplyr)
library(readr)

func_paste <- function(x, collapse = ",") paste(unique(x[!is.na(x)]), collapse = collapse)

# Import data
resfinder_reports <- get_data(
  ".",
  pattern = "resfinder_results.tsv",
  delim = "\t",
  col_names = TRUE,
  convert = TRUE
) %>%
  mutate(ref = sub("_resfinder_results.tsv", "", ref))

virfinder_reports <- get_data(
  ".",
  pattern = "virulencefinder_results.tsv",
  delim = "\t",
  col_names = TRUE,
  convert = TRUE
) %>%
  mutate(ref = sub("_virulencefinder_results.tsv", "", ref))

plasmidfinder_reports <- get_data(
  ".",
  pattern = "plasmidfinder_results.tsv",
  delim = "\t",
  col_names = TRUE,
  convert = TRUE
) %>%
  mutate(ref = sub("_plasmidfinder_results.tsv", "", ref))

mobsuite_reports <- get_data(
  ".",
  pattern = "contig_report.txt",
  delim = "\t",
  col_names = TRUE,
  convert = TRUE
) %>%
  mutate(ref = sub(".contig_report.txt", "", ref))

amrfinderplus_reports <- get_data(
  ".",
  pattern = "amrfinderplus_results.tsv",
  delim = "\t",
  col_names = TRUE,
  convert = TRUE
) %>%
  mutate(ref = sub("_amrfinderplus_results.tsv", "", ref))

# Write data to files
write_delim(
  resfinder_reports,
  "resfinder_report.tsv",
  delim = "\t"
)

write_delim(
  virfinder_reports,
  "virulencefinder_report.tsv",
  delim = "\t"
)

write_delim(
  plasmidfinder_reports,
  "plasmidfinder_report.tsv",
  delim = "\t"
)

write_delim(
  mobsuite_reports,
  "mobsuite_report.tsv",
  delim = "\t"
)

write_delim(
  amrfinderplus_reports,
  "amrfinderplus_report.tsv",
  delim = "\t"
)

# Generate summary report
summary_report <- mobsuite_reports %>%
  rename(
    "mobsuite_rep_types" = `rep_type(s)`
  ) %>%
  select(
    ref,
    contig_id,
    molecule_type,
    primary_cluster_id,
    secondary_cluster_id,
    size,
    gc,
    circularity_status,
    mobsuite_rep_types
  ) %>%
  left_join(
    plasmidfinder_reports %>%
      select(
        ref,
        Contig,
        Plasmid
      ) %>%
      group_by(ref, Contig) %>%
      summarise_all(list(func_paste)) %>%
      ungroup(), 
    by = c("ref","contig_id" = "Contig")) %>%
  rename(
    "plasmidfinder_plasmid" = Plasmid
  ) %>%
  left_join(
    resfinder_reports %>%
      select(
        ref, 
        Contig, 
        `Resistance gene`
        ) %>%
      group_by(ref, Contig) %>%
      summarise_all(list(func_paste)) %>%
      ungroup(), 
    by = c("ref","contig_id" = "Contig")) %>%
  rename(
    "resfinder_gene" = `Resistance gene`
  ) %>%
  left_join(
    virfinder_reports %>%
      select(
        ref,
        Contig,
        `Virulence factor`
      ) %>%
      group_by(ref, Contig) %>%
      summarise_all(list(func_paste)) %>%
      ungroup(), 
    by = c("ref", "contig_id" = "Contig")
    ) %>%
  rename(
    "virfinder_gene" = `Virulence factor`
  ) %>%
  mutate(
    contig_prefix = sub("(.+)\\ length=.+ | (.+)_length.+", "\\1", contig_id)
  ) %>%
  left_join(
    amrfinderplus_reports %>%
      select(
        ref,
        `Contig id`,
        `Element symbol`
      ) %>%
      group_by(ref, `Contig id`) %>%
      summarise_all(list(func_paste)) %>%
      ungroup(), 
    by = c("ref", "contig_prefix" = "Contig id")) %>%
  rename(
    "amrfinderplus_genes" = `Element symbol`
  ) %>%
  select(-contig_prefix)

write_delim(
  summary_report,
  "ellipsis_summary_report.tsv",
  delim = "\t"
)
