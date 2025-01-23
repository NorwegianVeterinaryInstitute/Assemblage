process SAMTOOLS {
	conda (params.enable_conda ? 'bioconda::samtools=1.3.1' : null)
	container 'quay.io/biocontainers/samtools:1.3.1--h0cf4675_11'

        input:
        tuple val(datasetID), file(bam)

        output:
	tuple val(datasetID), path("*mapped_sorted.bam"), emit: bam_ch

        """
	samtools sort $bam -o ${datasetID}_mapped_sorted.bam
	samtools index ${datasetID}_mapped_sorted.bam
        """
}

process SAMTOOLS_NP {
        conda (params.enable_conda ? 'bioconda::samtools=1.3.1' : null)
        container 'quay.io/biocontainers/samtools:1.3.1--h0cf4675_11'

        input:
        tuple val(datasetID), file(sam)

        output:
        tuple val(datasetID), path("*mapped_sorted.bam"), emit: bam_np_ch

        """
	samtools view -b $sam > ${datasetID}.bam
        samtools sort ${datasetID}.bam -o ${datasetID}_np_mapped_sorted.bam
        samtools index ${datasetID}_np_mapped_sorted.bam
        """
}
