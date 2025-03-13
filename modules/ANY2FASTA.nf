process ANY2FASTA {
	conda (params.enable_conda ? 'bioconda::any2fasta=0.4.2' : null)
	container 'quay.io/biocontainers/any2fasta:0.4.2--hdfd78af_3'

	label 'process_high_memory_time'

        input:
        tuple val(datasetID), path(gfa)

        output:
	tuple val(datasetID), path("${datasetID}_miniasm.fasta"), emit: miniasm_assembly_ch
	path "any2fasta.version"

	script:
        """
	any2fasta -v > any2fasta.version
	any2fasta $gfa > ${datasetID}_miniasm.fasta
	"""
}
