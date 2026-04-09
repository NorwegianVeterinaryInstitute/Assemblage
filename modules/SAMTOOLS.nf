process SAMTOOLS {
	conda (params.enable_conda ? 'bioconda::samtools=1.23.1' : null)
	container 'quay.io/biocontainers/samtools:1.23.1--ha83d96e_0'

    input:
    tuple val(datasetID), val(type), file(bam)

    output:
	path "*samtools_stats.txt", emit: samtools_stats_ch
	path "*samtools_coverage.txt", emit: samtools_cov_ch
	path "samtools.version", emit: samtools_version

	script:
	"""
	samtools --version > samtools.version
	samtools sort -o ${datasetID}_sorted.bam $bam
	samtools stats ${datasetID}_sorted.bam > ${datasetID}_${type}_samtools_stats.txt
	samtools coverage ${datasetID}_sorted.bam > ${datasetID}_${type}_samtools_coverage.txt
	"""
}
