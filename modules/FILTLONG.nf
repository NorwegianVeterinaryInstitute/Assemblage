process FILTLONG {
	conda (params.enable_conda ? 'bioconda::filtlong=0.3.1' : null)
	container 'quay.io/biocontainers/filtlong:0.3.1--h077b44d_0'

    input:
    tuple val(datasetID), file(reads)

    output:
    file("*")
	tuple val(datasetID), file("*_filtered.fastq.gz"), emit: filtlong_ch
	path "filtlong.version", emit: filtlong_version

	script:
	"""
	filtlong --version > filtlong.version
	filtlong --min_length $params.min_read_length --keep_percent $params.keep_percent $reads | gzip > ${datasetID}_filtered.fastq.gz
	"""
}
