process QUAST {
	conda (params.enable_conda ? 'bioconda::quast=5.2.0' : null)
	container 'quay.io/biocontainers/quast:5.2.0--py39pl5321h4e691d4_3'

        input:
        file("*")

        output:
        file("*")
        path "transposed_report.tsv", emit: R_quast
	path "quast.version"

        script:
        """
	quast --version > quast.version
        quast --threads $task.cpus -o . *.fasta
        """
}

process QUAST_COMPARE {
        conda (params.enable_conda ? 'bioconda::quast=5.2.0' : null)
        container 'quay.io/biocontainers/quast:5.2.0--py39pl5321h4e691d4_3'

        input:
        tuple val(datasetID), path(assembly_old), path(assembly_new)

        output:
        file("*")
	path "${datasetID}_transposed_report.tsv", emit: quast_compare_ch
	path "quast.version"

        script:
        """
	quast --version > quast.version
        quast --threads $task.cpus -o . --no-icarus --no-html -r $assembly_old $assembly_new
	mv transposed_report.tsv ${datasetID}_transposed_report.tsv
        """
}
