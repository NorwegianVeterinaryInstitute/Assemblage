process SAMTOOLS {
        tag "$datasetID"

        input:
        tuple val(datasetID), file(bam)

        output:
        file("*")
	tuple val(datasetID), path("*mapped_sorted.bam"), emit: bam_ch

        """
	samtools sort $bam -o ${datasetID}_mapped_sorted.bam
        """
}

