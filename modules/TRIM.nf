process TRIM {
	publishDir "${params.out_dir}/results/01_trimmed_reads/", pattern: "*val_{1,2}.fq.gz", mode: "copy"
	publishDir "${params.out_dir}/reports/01_trimming_reports/", pattern: "*trimming_report.txt", mode: "copy"

        tag "$datasetID"

        input:
        tuple val(datasetID), file(R1), file(R2)

        output:
        file("*")
        tuple val(datasetID), path {"*val_1.fq.gz"}, path {"*val_2.fq.gz"}, emit: trim_reads

        script:
        """
        trim_galore -o . --paired --quality $params.phred_score -e $params.error_rate --length $params.minlength -trim1 $R1 $R2 &> ${datasetID}_trimgalore.log
        """
}
