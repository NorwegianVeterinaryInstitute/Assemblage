process PLASMIDFINDER {
	conda (params.enable_conda ? 'bioconda::plasmidfinder=2.1.6' : null)
	container 'quay.io/biocontainers/plasmidfinder:2.1.6--py310hdfd78af_1'

        input:
        tuple val(datasetID), path(assembly), path(db)

        output:
        file("*")
	path "plasmidfinder.version"
	path "${datasetID}_plasmidfinder_results.tsv", emit: plasmidfinder_out_ch

        """
	echo "Plasmidfinder version 2.1.6" > plasmidfinder.version
	plasmidfinder.py -o . -l $params.mincov -t $params.identity_threshold -p $db -i $assembly -x
	mv results_tab.tsv ${datasetID}_plasmidfinder_results.tsv
	"""
}
