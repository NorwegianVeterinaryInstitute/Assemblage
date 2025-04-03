process FLYE {
	conda (params.enable_conda ? 'bioconda::flye=2.9.5' : null)
	container 'quay.io/biocontainers/flye:2.9.5--py310h275bdba_2'

	label 'process_high_memory_time'

    input:
    tuple val(datasetID), path(reads)

    output:
	tuple val(datasetID), path("*.fasta"), emit: flye_assembly_ch
	path "flye.version"

	script:
    """
	fastaname=\$(basename ${reads} | cut -d. -f1)
	flye --version > flye.version
	flye --nano-hq $reads --threads $task.cpus --out-dir flye
	cp flye/assembly.fasta \${fastaname}_flye.fasta
	"""
}
