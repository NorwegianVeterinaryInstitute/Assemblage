process PLASMIDFINDER {
	conda (params.enable_conda ? 'bioconda::plasmidfinder=2.1.6' : null)
	container 'quay.io/biocontainers/plasmidfinder:2.1.6--py310hdfd78af_1'

        input:
        tuple val(datasetID), path(assembly)

        output:
        file("*")

        """
	plasmidfinder.py -o . -l $params.mincov -t $params.identity_threshold -p $params.plasmidfinder_db -i $assembly -x
	"""
}
