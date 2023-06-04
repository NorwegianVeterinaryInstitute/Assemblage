process BWA {
	conda (params.enable_conda ? 'bioconda::bwa=0.7.8' : null)
	container 'quay.io/biocontainers/bwa:0.7.8--he4a0461_9'

        label 'process_high_memory_time'

        input:
        tuple val(datasetID), file(R1), file(R2), file(ref)

        output:
        file("*")
        tuple val(datasetID), path("${datasetID}.bam"), emit: samtools_ch

        """
	bwa index $ref
	bwa mem -t $task.cpus $ref $R1 $R2 > ${datasetID}.bam
        """
}

