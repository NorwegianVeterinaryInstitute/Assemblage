process POLCA {
	conda (params.enable_conda ? 'bioconda::masurca=4.1.0' : null)
	container 'quay.io/biocontainers/masurca:4.1.0--pl5321hb5bd705_1'

        input:
        tuple val(datasetID), file(R1), file(R2), file(assembly)

        output:
        file("*")

        """
	polca.sh -a $assembly -r '$R1 $R2' -t $task.cpus 
	"""
}
