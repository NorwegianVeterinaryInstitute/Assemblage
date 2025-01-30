process SAMTOOLS {
	conda (params.enable_conda ? 'bioconda::samtools=1.3.1' : null)
	container 'quay.io/biocontainers/samtools:1.3.1--h0cf4675_11'

        input:
        tuple val(datasetID), file(bam), val(seq)

        output:
	tuple val(datasetID), path("*mapped_sorted.bam"), env(seqtype), emit: bam_ch

	script:
	if( seq == "illumina" )
	    """
	    samtools sort $bam -o ${datasetID}_mapped_sorted.bam
            samtools index ${datasetID}_mapped_sorted.bam
	    seqtype="illumina"
	    """
	else if( seq == "nanopore" )
	    """
	    samtools view -b $bam > ${datasetID}.bam
            samtools sort ${datasetID}.bam -o ${datasetID}_np_mapped_sorted.bam
            samtools index ${datasetID}_np_mapped_sorted.bam
	    seqtype="nanopore"
	    """
}
