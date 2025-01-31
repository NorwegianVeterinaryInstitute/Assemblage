process RESFINDER {
	conda (params.enable_conda ? 'bioconda::resfinder=4.6.0' : null)
	container 'quay.io/biocontainers/resfinder:4.6.0--pyhdfd78af_0'

        input:
        tuple val(datasetID), path(assembly)

        output:
        file("*")

        """
	python -m resfinder -o . -s $params.species -l $params.mincov -t $params.identity_threshold --acquired --disinfectant --point --ignore_missing_species -ifa $assembly
	"""
}
