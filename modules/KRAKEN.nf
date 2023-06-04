process KRAKEN {
	conda (params.enable_conda ? 'bioconda::kraken2=2.1.2' : null)
	container 'quay.io/biocontainers/kraken2:2.1.2--pl5321h4ac6f70_4'

        input:
        tuple val(datasetID), file(R1), file(R2)

        output:
        file("*")

        script:
        """
	kraken2 --db $params.kraken_db --paired $R1 $R2 --threads $task.cpus --output ${datasetID}.kr2.out --report ${datasetID}kr2.report --use-names
        """
}
