process BEDTOOLS {
	publishDir "${params.out_dir}/02_ASSEMBLY/04_coverage_reports", pattern: "*_genomecov.txt", mode: "copy"

        tag "$datasetID"

        input:
        tuple val(datasetID), file(bam)

        output:
        file("*")

        """
	bedtools genomecov -ibam $bam -d > ${datasetID}_genomecov.txt
        """
}

