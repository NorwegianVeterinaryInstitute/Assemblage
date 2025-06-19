process MEDAKA {
	conda (params.enable_conda ? 'bioconda::medaka=2.1.0' : null)
	container 'quay.io/biocontainers/medaka:2.1.0--py38ha0c3a46_0'

    input:
    tuple val(datasetID), path(assembly), path(np)

    output:
	path "medaka.version"

    """
	medaka --version > medaka.version
	fastplong -i $NP -o ${datasetID}_fastp.fastq.gz --failed_out ${datasetID}_failed.fastq.gz -m $params.fastp_mean_phred -l $params.fastp_minlen --json ${datasetID}_fastp.json --html ${datasetID}_fastp.html --report_title "$datasetID" --thread $task.cpus 
    """
}
