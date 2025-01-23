process POLYPOLISH {
	conda (params.enable_conda ? 'bioconda::polypolish=0.6.0' : null)
	container 'quay.io/biocontainers/polypolish:0.6.0--h4c94732_1'

        input:
        tuple val(datasetID), file(assembly), file(alignment1), file(alignment2)

        output:
        file("*")

        """
	polypolish_insert_filter.py --in1 $alignment1 --in2 $alignment2 --out1 filtered_1.sam --out2 filtered_2.sam
	polypolish $assembly filtered_1.sam filtered_2.sam > ${datasetID}_filtered.fasta
	"""
}
