process AMRFINDERPLUS {
	conda (params.enable_conda ? 'bioconda::ncbi-amrfinderplus=4.2.7' : null)
	container 'ncbi/amr:4.2.7-2026-03-24.1'

    input:
    tuple val(datasetID), path(assembly)

    output:
	path "amrfinderplus.version", emit: amrfinderplus_version
	path "${datasetID}_amrfinderplus_results.tsv", emit: amrfinderplus_out_ch

    script:
    def args = task.ext.args ?: ""

    """
    mkdir -p tmp
    export TMPDIR=\$PWD/tmp
    export TMP=\$PWD/tmp

    amrfinder --version > amrfinderplus.version
    amrfinder -o ${datasetID}_amrfinderplus_results.tsv --nucleotide $assembly --threads $task.cpus --name $datasetID $args 
    """
}
