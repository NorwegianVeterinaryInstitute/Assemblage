process POLYPOLISH {
	conda (params.enable_conda ? 'bioconda::polypolish=0.6.0' : null)
	container 'quay.io/biocontainers/polypolish:0.6.0--h4c94732_1'

        input:
        tuple val(datasetID), path(assembly), path(alignment1), path(alignment2)

        output:
        file("*")
	tuple val(datasetID), path {"*_polished.fasta"}, emit: polished_assemblies_ch
	path "polypolish.version"

        """
	polypolish --version > polypolish.version
	polypolish filter --in1 $alignment1 --in2 $alignment2 --out1 filtered_1.sam --out2 filtered_2.sam
	polypolish polish $assembly filtered_1.sam filtered_2.sam | sed 's/ polypolish//' > ${datasetID}_polished.fasta
	"""
}
