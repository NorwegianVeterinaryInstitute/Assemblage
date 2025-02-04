process FILTLONG {
	conda (params.enable_conda ? 'bioconda::filtlong=0.2.1' : null)
	container 'quay.io/biocontainers/filtlong:0.2.1--hd03093a_2'

        input:
        tuple val(datasetID), file(reads)

        output:
        file("*")
	tuple val(datasetID), file("*_filtered.fastq.gz"), emit: filtlong_ch
	path "filtlong.version"

        """
	filtlong --version > filtlong.version
	filtlong --min_length $params.min_read_length --keep_percent $params.keep_percent $reads | gzip > ${datasetID}_filtered.fastq.gz
	"""
}
