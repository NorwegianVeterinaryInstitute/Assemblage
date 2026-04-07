process AMRFINDERPLUS {
	conda (params.enable_conda ? 'bioconda::ncbi-amrfinderplus=4.2.7' : null)
	container 'quay.io/biocontainers/ncbi-amrfinderplus:4.2.7--hf69ffd2_0'

    input:
    tuple val(datasetID), path(assembly), path(db), path(aa), path(gff)

    output:
	path "amrfinderplus.version", emit: amrfinderplus_version
	path "${datasetID}_amrfinderplus_results.tsv", emit: amrfinderplus_out_ch

    script:
    def args = task.ext.args ?: ""

    """
    amrfinderplus --version > amrfinderplus.version
    amrfinderplus -o . --nucleotide $assembly --protein $aa --gff $gff --name $datasetID --db_path_amrfinderplus $db $args
	"""
}
