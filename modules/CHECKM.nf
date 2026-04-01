process CHECKM2 {
    conda (params.enable_conda ? 'bioconda::checkm2=1.1.0' : null)
	container 'quay.io/staphb/checkm2:1.1.0'

    input:
    path("*")

    output:
    path("quality_report.tsv"), emit: checkm2_ch

    script:
    """
    checkm2 predict --input *fasta --output-directory . --database-path $params.checkm2_db
    """
}