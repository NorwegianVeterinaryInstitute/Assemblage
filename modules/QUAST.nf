process QUAST {
	conda (params.enable_conda ? 'bioconda::quast=5.2.0' : null)
	container 'quay.io/biocontainers/quast:5.2.0--py39pl5321h4e691d4_3'

        input:
        file("*")

        output:
        file("*")
        path "transposed_report.tsv", emit: R_quast

        script:
        """
        quast --threads $task.cpus -o . *.fasta
        """
}
