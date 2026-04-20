process CANU {
	conda (params.enable_conda ? 'bioconda::canu=2.2' : null)
	container 'quay.io/biocontainers/canu:2.2--ha47f30e_0'

	label 'process_high_memory_time'

    input:
    tuple val(datasetID), path(reads), val(genome_size)

    output:
	tuple val(datasetID), path("*.fasta"), emit: canu_assembly_ch
	path "canu.version", emit: canu_version

	script:

	def args = task.ext.args ?: ''

    """
	fastaname=\$(basename ${reads} | cut -d. -f1)
	canu --version > canu.version
	canu -p \${fastaname}_canu -d canu genomeSize=$genome_size useGrid=false maxThreads=$task.cpus -nanopore $reads $args
	mv canu/*contigs.fasta .
	"""

	stub:
	"""
	cp $baseDir/assets/data/test_assembly.fasta ${datasetID}_canu.fasta
	echo "Canu version 2.2" > canu.version
	"""
}