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
