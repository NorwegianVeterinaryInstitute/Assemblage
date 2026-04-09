process SEQKIT_FILTER {
	conda (params.enable_conda ? 'bioconda::seqkit=2.10.0' : null)
	container 'quay.io/biocontainers/seqkit:2.10.0--he881be0_1'

    input:
    tuple val(datasetID), path(assembly)
	
    output:
	path "seqkit.version", emit: seqkit_version
	tuple val(datasetID), path("${datasetID}_filtered.fasta"), emit: seqkit_filtered_ch
    path "${datasetID}_filtered.fasta", emit: seqkit_quast_ch

    """
    seqkit version > seqkit.version
    seqkit seq -m $params.min_contig_len $assembly > ${datasetID}_filtered.fasta
	"""
}