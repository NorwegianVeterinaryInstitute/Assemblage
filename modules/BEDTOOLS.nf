process BEDTOOLS {
	publishDir "${params.out_dir}/reports/coverage_reports", pattern: "*_genomecov.txt", mode: "copy"

        tag "$datasetID"

        input:
        tuple val(datasetID), file(bam)

        output:
        file("*")
	tuple val(datasetID), path("*mapped_sorted.bam"), emit: bam_ch

        """
	bedtools genomecov -ibam $bam -d > ${datasetID}_genomecov.txt
        """
}

