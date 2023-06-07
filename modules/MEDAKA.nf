process MEDAKA {
	conda (params.enable_conda ? 'bioconda::medaka=1.8.0' : null)
	container 'quay.io/biocontainers/medaka:1.8.0--py38hdaa7744_0'

        input:
        tuple val(datasetID), file(np_reads), file(assembly)

        output:
        file("*")
	tuple val(datasetID), file("consensus.fasta"), emit: medaka_ch

        """
	medaka_consensus -i $np_reads -d $assembly -m $params.basecalling_model -t $task.cpus -o .
	"""
}
