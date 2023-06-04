process UNICYCLER {
	conda (params.enable_conda ? 'bioconda::unicycler=0.5.0' : null)
	container 'quay.io/biocontainers/unicycler:0.5.0--py310h6cc9453_3'

	label 'process_high_memory_time'

        input:
        tuple val(datasetID), file(R1), file(R2)

        output:
        file("*")
        path("*.fasta"), emit: quast_ch
	tuple val(datasetID), path("*.fasta"), emit: assembly_ch

        """
        unicycler -1 $R1 -2 $R2 -o . --verbosity 2 --keep 2 --mode $params.mode --threads $task.cpus --min_fasta_length $params.min_fasta_length --depth_filter $params.depth_filter
        mv assembly.fasta ${datasetID}.fasta
        mv unicycler.log ${datasetID}_unicycler.log
	"""
}

process UNICYCLER_HYBRID {
        conda (params.enable_conda ? 'bioconda::unicycler=0.5.0' : null)
        container 'quay.io/biocontainers/unicycler:0.5.0--py310h6cc9453_3'

        label 'process_high_memory_time'

        input:
        tuple val(datasetID), file(R1), file(R2), file(longreads)

        output:
        file("*")
        path("*.fasta"), emit: quast_ch
        tuple val(datasetID), path("*.fasta"), emit: assembly_ch

        """
	unicycler -1 $R1 -2 $R2 -l $longreads  -o . --verbosity 2 --keep 2 --mode $params.mode --threads $task.cpus --min_fasta_length $params.min_fasta_length --depth_filter $params.depth_filter
        mv assembly.fasta ${datasetID}.fasta
        mv unicycler.log ${datasetID}_unicycler.log
        """
}
