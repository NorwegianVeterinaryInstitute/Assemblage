process VIRULENCEFINDER {
	conda (params.enable_conda ? 'bioconda::virulencefinder=2.0.4' : null)
	container 'quay.io/biocontainers/virulencefinder:2.0.4--hdfd78af_1'

        input:
        tuple val(datasetID), path(assembly), path(db)
	
        output:
        file("*")
	path "virulencefinder.version"
	path "${datasetID}_virulencefinder_results.tsv", emit: virfinder_out_ch

        """
	echo "Virulencefinder version 2.0.4" > virulencefinder.version
	virulencefinder.py -o . -l $params.mincov -t $params.identity_threshold -p $db -i $assembly -x
	mv results_tab.tsv ${datasetID}_virulencefinder_results.tsv
	"""
}
