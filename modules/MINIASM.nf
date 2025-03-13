process MINIASM {
	conda (params.enable_conda ? 'bioconda::miniasm=0.3' : null)
	container 'quay.io/biocontainers/miniasm:0.3--h577a1d6_5'

	label 'process_high_memory_time'

        input:
        tuple val(datasetID), path(NP), path(paf)

        output:
	tuple val(datasetID), path(NP), path("*.gfa"), emit: miniasm_gfa_ch
	path "miniasm.version"

	script:
        """
	miniasm --version > miniasm.version
	miniasm -f $NP $paf > ${datasetID}_unpolished.gfa
	"""
}
