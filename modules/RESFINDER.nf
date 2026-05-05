process RESFINDER {
	conda (params.enable_conda ? 'bioconda::resfinder=4.6.0' : null)
	container 'quay.io/biocontainers/resfinder:4.6.0--pyhdfd78af_0'

    input:
    tuple val(datasetID), path(assembly), path(db)

    output:
    file("*")
	path "resfinder.version", emit: resfinder_version
	path "${datasetID}_resfinder_results.tsv", emit: resfinder_out_ch

	script:
	def args = task.ext.args ?: ""

    """
	python -m resfinder --version > resfinder.version
	python -m resfinder -o . --acquired --db_path_res $db -ifa $assembly $args
	mv ResFinder_results_tab.txt ${datasetID}_resfinder_results.tsv
	"""
}
