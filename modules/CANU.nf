process CANU {
	conda (params.enable_conda ? 'bioconda::canu=2.3' : null)
	container 'quay.io/biocontainers/canu:2.3--h3fb4750_0'

	label 'process_high_memory_time'

        input:
        tuple val(datasetID), path(reads)

        output:
	tuple val(datasetID), path("*.fasta"), emit: canu_assembly_ch
	path "canu.version"

	script:
        """
	canu --version > canu.version
	canu -p ${datasetID}_canu -d canu genomeSize=$params.genome_size useGrid=false maxThreads=$task.cpus -nanopore $reads
	"""
}
