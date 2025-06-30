process MEDAKA {
	conda (params.enable_conda ? 'bioconda::medaka=2.1.0' : null)
	container 'quay.io/biocontainers/medaka:2.1.0--py38ha0c3a46_0'

    input:
    tuple val(datasetID), path(assembly), path(np)

    output:
	path "medaka.version"
    tuple val(datasetID), path("consensus.fasta"), emit: medaka_consensus_ch

    """
	medaka --version > medaka.version
    medaka consensus -i $assembly -d $np -o . -t ${task.cpus} --bacteria
    mv consensus.fasta ${datasetID}_consensus.fasta
    """
}
