process RASUSA {
	conda (params.enable_conda ? 'bioconda::rasusa=0.8.0' : null)
	container 'quay.io/biocontainers/rasusa:0.8.0--h031d066_0'

        input:
        tuple val(datasetID), path(R1), path(R2)

        output:
        file("*")
        tuple val(datasetID), path {"*rasusa_1.fq.gz"}, path {"*rasusa_2.fq.gz"}, emit: subsampled_reads
	path "rasusa.version"

        script:
        """
	rasusa --version > rasusa.version
	rasusa --input $R1 $R2 --genome-size $params.genome_size --coverage $params.coverage --output ${datasetID}_rasusa_1.fq.gz ${datasetID}_rasusa_2.fq.gz &> rasusa.log
	mv rasusa.log ${datasetID}_rasusa.log
        """
}
