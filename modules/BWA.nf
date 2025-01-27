process BWA {
	conda (params.enable_conda ? 'bioconda::bwa=0.7.8' : null)
	container 'quay.io/biocontainers/bwa:0.7.8--he4a0461_9'

        label 'process_high_memory_time'

        input:
        tuple val(datasetID), file(R1), file(R2), file(ref)

        output:
        file("*.bam")
        tuple val(datasetID), path("${datasetID}.bam"), val("illumina"), emit: samtools_bwa_ch
	tuple val(datasetID), path("${datasetID}_alignments1.sam"), path("${datasetID}_alignments2.sam"), emit: bwa_polypolish_ch

	script:
        """
	bwa index $ref
	bwa mem -t $task.cpus $ref $R1 $R2 > ${datasetID}.bam
	bwa mem -t $task.cpus -a $ref $R1 > ${datasetID}_alignments1.sam
	bwa mem -t $task.cpus -a $ref $R2 > ${datasetID}_alignments2.sam
        """
}
