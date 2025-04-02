process AUTOCYCLER_SUBSET {
	conda (params.enable_conda ? 'bioconda::autocycler=0.2.1' : null)
	container 'evezeyl/autocycler:0.2.1'

    input:
    tuple val(datasetID), file(reads)

    output:
	path "autocycler.version"
	tuple val(datasetID), path("sample_*"), emit: sub_ch

	"""
	autocycler --version > autocycler.version
	autocycler subsample --reads $reads --out_dir . --genome_size $params.genome_size --count 12 --min_read_depth $params.min_read_depth
	"""
}
