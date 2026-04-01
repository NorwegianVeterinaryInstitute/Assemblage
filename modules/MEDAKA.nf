process MEDAKA {
	conda (params.enable_conda ? 'bioconda::medaka=2.1.0' : null)
	container 'quay.io/biocontainers/medaka:2.1.0--py38ha0c3a46_0'

    input:
    tuple val(datasetID), path(assembly), path(np)

    output:
	path "medaka.version", emit: medaka_version
    tuple val(datasetID), path("*_medaka_consensus.fasta"), emit: medaka_consensus_ch

    """
	medaka --version > medaka.version
    medaka_consensus -i $assembly -d $np -o results -t ${task.cpus} --bacteria
    mv results/consensus.fasta ${datasetID}_medaka_consensus.fasta
    """
}
