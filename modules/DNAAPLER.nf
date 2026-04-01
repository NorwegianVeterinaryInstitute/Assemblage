process DNAAPLER {
	conda (params.enable_conda ? 'bioconda::dnaapler=1.2.0' : null)
	container 'quay.io/biocontainers/dnaapler:1.2.0--pyhdfd78af_0'

    input:
    tuple val(datasetID), path(gfa)

    output:
    tuple val(datasetID), path("${datasetID}_dnaapler_reoriented.gfa"), emit: dnaapler_reoriented_ch
    path "dnaapler.version", emit: dnaapler_version

	"""
    dnaapler --version > dnaapler.version
	dnaapler all -i $gfa -o results -t $task.cpus
    mv results/dnaapler_reoriented.gfa ${datasetID}_dnaapler_reoriented.gfa
	"""
}
process DNAAPLER_FASTA {
    conda (params.enable_conda ? 'bioconda::dnaapler=1.2.0' : null)
    container 'quay.io/biocontainers/dnaapler:1.2.0--pyhdfd78af_0'

    label 'process_high_memory_time'

    input:
    tuple val(datasetID), path(assembly)

    output:
    path "*fasta", emit: quast_ch
    tuple val(datasetID), path("${datasetID}_dnaapler_reoriented.fasta"), emit: dnaapler_reoriented_ch
    path("${datasetID}_contig_names.txt"), emit: r_contig_names_ch
    path "dnaapler.version", emit: dnaapler_version

    script:
    """
    dnaapler --version > dnaapler.version
    dnaapler all \\
        -i $assembly \\
        -o results \\
        -p ${datasetID} \\
        -t $task.cpus

    mv results/${datasetID}_reoriented.fasta ${datasetID}_dnaapler_reoriented.fasta
    grep "^>" ${datasetID}_dnaapler_reoriented.fasta > ${datasetID}_contig_names.txt
    """
}