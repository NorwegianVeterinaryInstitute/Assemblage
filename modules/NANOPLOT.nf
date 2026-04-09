process NANOPLOT {
    conda (params.enable_conda ? 'bioconda::nanoplot=1.46.2' : null)
    container 'quay.io/biocontainers/nanoplot:1.46.2--pyhdfd78af_1'

    label 'process_high_memory_time'

    input:
    tuple val(datasetID), path(np)

    output:
    path "nanoplot.version", emit: nanoplot_version

    script:
    """
    NanoPlot --version > nanoplot.version
    NanoPlot --fastq $np --no-static -o . -t $task.cpus
    mv nanoplot_report.html ${datasetID}_nanoplot_report.html
    """
}