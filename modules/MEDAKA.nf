process MEDAKA {
	conda (params.enable_conda ? 'bioconda::medaka=1.11.3' : null)
	container 'quay.io/biocontainers/medaka:1.11.3--py39h05d5c5e_0'

        input:
        tuple val(datasetID), file(np_reads), file(assembly)

        output:
        file("*")
	tuple val(datasetID), file("consensus.fasta"), emit: medaka_output_ch

        """
	medaka_consensus -i $np_reads -d $assembly -m $params.basecalling_model -t $task.cpus -o .
	"""
}
