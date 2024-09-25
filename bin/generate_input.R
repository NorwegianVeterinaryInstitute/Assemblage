#!/usr/bin/env Rscript

args <- commandArgs(trailingOnly = TRUE)

option <- args[1]
r1 <- args[4]
r2 <- args[5]

if (option == "illumina") {
    path <- args[2]
    pattern <- args[3]

    if (grepl("/$", path) == FALSE) {
       path <- paste0(path, "/")
    }

    files <- list.files(path = path,
                        pattern = pattern)

    files_path <- paste0(path, files)

    filenames <- unique(sub(pattern, "", files))
    df <- data.frame(sample = filenames)
    forward <- grep(r1, files_path, value = TRUE)
    reverse <- grep(r2, files_path, value = TRUE)

    df$R1 <- forward
    df$R2 <- reverse

    write.table(
      x = df,
      file = "samplesheet.csv",
      quote = FALSE,
      row.names = FALSE,
      sep = ","
    )

} else if (option == "hybrid") {
    path1 <- args[2]
    path2 <- args[3]
    pattern <- args[4]

    if (grepl("/$", path1) == FALSE) {
      path1 <- paste0(path1, "/")
    }

    if (grepl("/$", path2) == FALSE) {
      path2 <- paste0(path2, "/")
    }

    files <- list.files(path = path1,
                        pattern = pattern)

    np_files <- list.files(path = path2,
                           pattern = ".fastq.gz")

    filenames <- sub(pattern, "", files)
    filenames_np <- sub(".fastq.gz", "", np_files)

    df <- data.frame(sample = filenames)
    df$path <- paste0(path1, files)
    df$read <- ifelse(grepl("_R1.fastq.gz", df$path), "R1", "R2")

    df_np <- data.frame(sample = filenames_np,
                        NP = paste0(path2, np_files))

    il_samplesheet <- reshape(
      data = df,
      direction = "wide",
      v.names = "path",
      idvar = "sample",
      timevar = "read"
    )

    samplesheet <- merge(
      x = il_samplesheet,
      y = df_np,
      by = "sample",
      all = TRUE
    )

    names(samplesheet) <- c("sample","R1","R2","NP")

    write.table(
      x         = samplesheet,
      file      = "samplesheet.csv",
      quote     = FALSE,
      row.names = FALSE,
      sep       = ","
    )
}
