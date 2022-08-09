process KRAKEN {
	publishDir "${params.out_dir}/01_QC/04_kraken_reports", pattern: "*kr2.out", mode: "copy"
	publishDir "${params.out_dir}/01_QC/04_kraken_reports", pattern: "*kr2.report", mode: "copy"
	
        tag "$datasetID"

        input:
        tuple val(datasetID), file(R1), file(R2)

        output:
        file("*")

        script:
        """
	kraken2 --db $params.kraken_db --paired $R1 $R2 --threads $task.cpus --output ${datasetID}.kr2.out --report ${datasetID}kr2.report --use-names
        """
}
