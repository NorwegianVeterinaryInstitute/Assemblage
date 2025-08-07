process CANU {
	conda (params.enable_conda ? 'bioconda::canu=2.2' : null)
	container 'quay.io/biocontainers/canu:2.2--ha47f30e_0'

	label 'process_high_memory_time'

    input:
    tuple val(datasetID), path(reads)

    output:
	tuple val(datasetID), path("*.fasta"), emit: canu_assembly_ch
	path "canu.version"

	script:
    """
	fastaname=\$(basename ${reads} | cut -d. -f1)
	canu --version > canu.version
	canu -p \${fastaname}_canu -d canu genomeSize=$params.genome_size useGrid=false maxThreads=$task.cpus -nanopore $reads
	mv canu/*contigs.fasta .
	"""
}