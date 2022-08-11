process BWA {
        publishDir "${params.out_dir}/02_ASSEMBLY/03_mapping/", pattern: "${datasetID}.bam", mode: "copy"

        tag "$datasetID"
        label 'bigmem'

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

