process FASTQC {
	conda (params.enable_conda ? 'bioconda::fastqc=0.12.1' : null)
	container 'quay.io/biocontainers/fastqc:0.12.1--hdfd78af_0'

        input:
        tuple val(datasetID), path(R1), path(R2)

        output:
        file("*")
        path "$datasetID/*_fastqc.zip", emit: fastqc_reports
	path "fastqc.version"

        """
	fastqc --version > fastqc.version
        mkdir $datasetID
        fastqc $R1 $R2 -o $datasetID -t $task.cpus
        """
}
