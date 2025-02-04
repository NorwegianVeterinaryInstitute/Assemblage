process RESFINDER {
	conda (params.enable_conda ? 'bioconda::resfinder=4.6.0' : null)
	container 'quay.io/biocontainers/resfinder:4.6.0--pyhdfd78af_0'

        input:
        tuple val(datasetID), path(assembly), path(db)

        output:
        file("*")
	path "resfinder.version"

        """
	python -m resfinder --version > resfinder.version
	python -m resfinder -o . -s $params.species -l $params.mincov -t $params.identity_threshold --acquired --db_path_res $db --ignore_missing_species -ifa $assembly
	"""
}
