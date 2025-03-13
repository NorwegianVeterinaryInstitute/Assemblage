process RAVEN {
	conda (params.enable_conda ? 'bioconda::raven-assembler=1.8.3' : null)
	container 'quay.io/biocontainers/raven-assembler:1.8.3--h5ca1c30_3'

	label 'process_high_memory_time'

        input:
        tuple val(datasetID), path(reads)

        output:
	tuple val(datasetID), path("*.fasta"), emit: raven_assembly_ch
	path "raven.version"

	script:
        """
	raven --version > raven.version
	raven --threads $task.cpus --disable-checkpoints $reads > ${datasetID}_raven.fasta
	"""
}
