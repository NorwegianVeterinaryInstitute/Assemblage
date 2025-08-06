process DNAAPLER {
	conda (params.enable_conda ? 'bioconda::dnaapler=1.2.0' : null)
	container 'quay.io/biocontainers/dnaapler:1.2.0--pyhdfd78af_0'

    input:
    tuple val(datasetID), path(gfa)

    output:
    tuple val(datasetID), path("${datasetID}_dnaapler_reoriented.gfa"), emit: dnaapler_reoriented_ch
    path "dnaapler.version"

	"""
    dnaapler --version > dnaapler.version
	dnaapler all -i $gfa -o results -t $task.cpus
    mv results/dnaapler_reoriented.gfa ${datasetID}_dnaapler_reoriented.gfa
	"""
}