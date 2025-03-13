process FASTPLONG {
	conda (params.enable_conda ? 'bioconda::fastplong=0.2.2' : null)
	container 'quay.io/biocontainers/fastplong:0.2.2--heae3180_0'

        input:
        tuple val(datasetID), path(NP)

        output:
        path "${datasetID}_fastp.json", emit: fastplong_ch
	path "fastplong.version"

        """
	fastplong --version > fastplong.version
	fastplong -i $NP -o ${datasetID}_fastp.fastq.gz --failed_out ${datasetID}_failed.fastq.gz -m $params.fastp_mean_phred -l $params.fastp_minlen --json ${datasetID}_fastp.json --html ${datasetID}_fastp.html --report_title "$datasetID" --thread $task.cpus 
        """
}
