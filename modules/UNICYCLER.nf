process UNICYCLER {
	conda (params.enable_conda ? 'bioconda::unicycler=0.5.0' : null)
	container 'quay.io/biocontainers/unicycler:0.5.0--py310h6cc9453_3'

	label 'process_high_memory_time'

        input:
        tuple val(datasetID), path(shortreads), path(longreads)

        output:
        file("*")
        path("*.fasta"), emit: quast_ch
	tuple val(datasetID), path("*.fasta"), emit: assembly_ch

	script:
	def args = task.ext.args ?: ''
        if (params.assembly_track == 'short'){
            input_reads = "-1 ${shortreads[0]} -2 ${shortreads[1]}"
        } else (params.assembly_track == 'hybrid'){
            input_reads = "-1 ${shortreads[0]} -2 ${shortreads[1]} -l $longreads"
        }
        """
        unicycler \\
		--threads $task.cpus \\
		$args \\
		$short_reads \\
		$long_reads

        mv assembly.fasta ${datasetID}.fasta
	sed -i 's/ /_/g' ${datasetID}.fasta
        mv unicycler.log ${datasetID}_unicycler.log
	"""
}
