process UNICYCLER {
	conda (params.enable_conda ? 'bioconda::unicycler=0.5.0' : null)
	container 'quay.io/biocontainers/unicycler:0.5.0--py310h6cc9453_3'

	label 'process_high_memory_time'

        input:
        tuple val(datasetID), path(R1), path(R2)

        output:
        file("*")
        path("*.fasta"), emit: quast_ch
	tuple val(datasetID), path("*.fasta"), emit: assembly_ch

	script:
	def args = task.ext.args ?: ''

        """
        unicycler \\
		--threads $task.cpus \\
		$args \\
		-1 $R1 -2 $R2 \\
		--out .

        mv assembly.fasta ${datasetID}.fasta
	sed -i 's/ /_/g' ${datasetID}.fasta
        mv unicycler.log ${datasetID}_unicycler.log
	"""
}

process UNICYCLER_HYBRID {
        conda (params.enable_conda ? 'bioconda::unicycler=0.5.0' : null)
        container 'quay.io/biocontainers/unicycler:0.5.0--py310h6cc9453_3'

        label 'process_high_memory_time'

        input:
        tuple val(datasetID), path(R1), path(R2), path(np)

        output:
        file("*")
        path("*.fasta"), emit: quast_ch
        tuple val(datasetID), path("*.fasta"), emit: assemblies_ch

        script:
        def args = task.ext.args ?: ''

        """
        unicycler \\
                --threads $task.cpus \\
                $args \\
                -1 $R1 -2 $R2 \\
		-l $np \\
                --out .

        mv assembly.fasta ${datasetID}.fasta
        sed -i 's/ /_/g' ${datasetID}.fasta
        mv unicycler.log ${datasetID}_unicycler.log
        """
}
