process VIRULENCEFINDER {
	conda (params.enable_conda ? 'bioconda::virulencefinder=2.0.4' : null)
	container 'quay.io/biocontainers/virulencefinder:2.0.4--hdfd78af_1'

        input:
        tuple val(datasetID), path(assembly), path(db)
	
        output:
        file("*")

        """
	virulencefinder.py -o . -l $params.mincov -t $params.identity_threshold -p $db -i $assembly -x
	"""
}
