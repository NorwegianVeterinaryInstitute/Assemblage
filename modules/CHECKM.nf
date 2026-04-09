process CHECKM2 {
    conda (params.enable_conda ? 'bioconda::checkm2=1.0.2' : null)
	container 'quay.io/biocontainers/checkm2:1.0.2--pyh7cba7a3_0'

    input:
    path("*")

    output:
    path("quality_report.tsv"), emit: checkm2_ch
    path("checkm2.version"), emit: checkm2_version

    script:
    """
    checkm2 --version > checkm2.version
    checkm2 predict --input *fasta --threads $task.cpus --output-directory results --database_path $params.checkm2_db
    cp results/quality_report.tsv quality_report.tsv
    """
}