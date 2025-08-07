process MINIPOLISH {
	conda (params.enable_conda ? 'bioconda::minipolish=0.1.3' : null)
	container 'quay.io/biocontainers/minipolish:0.1.3--pyhdfd78af_0'

	label 'process_high_memory_time'

    input:
    tuple val(datasetID), path(NP), path(gfa)

    output:
	tuple val(datasetID), path("*.gfa"), emit: miniasm_polished_ch
	path "minipolish.version"

	script:
    """
	fastaname=\$(basename ${gfa} | cut -d. -f1)
	minipolish --version > minipolish.version
    minipolish --threads $task.cpus $NP $gfa > \${fastaname}_assembly.gfa
	"""
}
