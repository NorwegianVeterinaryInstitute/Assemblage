process QUAST {
	conda (params.enable_conda ? 'bioconda::quast=5.2.0' : null)
	container 'quay.io/biocontainers/quast:5.2.0--py39pl5321h4e691d4_3'

        tag "batch_${batch_id}"

        input:
        tuple val(batch_id), path(genomes)

        output:
        tuple val(batch_id), path("quast_batch_${batch_id}_out"), emit: quast_multiqc_ch
	path("${batch_id}_quast_report.tsv"), emit: quast_report_ch
        path "quast.version", emit: quast_version

        script:
        """
	quast --version > quast.version
        quast --threads $task.cpus -o quast_batch_${batch_id}_out ${genomes.join(' ')}
        cp quast_batch_${batch_id}_out/transposed_report.tsv ${batch_id}_quast_report.tsv
        """
}

process QUAST_COMPARE {
        conda (params.enable_conda ? 'bioconda::quast=5.2.0' : null)
        container 'quay.io/biocontainers/quast:5.2.0--py39pl5321h4e691d4_3'

        input:
        tuple val(datasetID), path(assembly_old), path(assembly_new)

        output:
	path "${datasetID}_transposed_report.tsv", emit: quast_compare_ch
	path "quast.version", emit: quast_version

        script:
        """
	quast --version > quast.version
        quast --threads $task.cpus -o . --no-icarus --no-html -r $assembly_old $assembly_new
	mv transposed_report.tsv ${datasetID}_transposed_report.tsv
        """
}
