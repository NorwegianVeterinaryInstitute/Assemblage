process BEDTOOLS {
	conda (params.enable_conda ? 'bioconda::bedtools=2.31.0' : null)
	container 'quay.io/biocontainers/bedtools:2.31.0--h468198e_0'

        input:
        tuple val(datasetID), file(bam)

        output:
        file("*")
	path "*genomecov.txt", emit: cov_report_ch

        """
	bedtools genomecov -ibam $bam -d > ${datasetID}_genomecov.txt
        """
}

