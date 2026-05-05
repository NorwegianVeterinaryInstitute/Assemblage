process MULTIQC {
	conda (params.enable_conda ? 'bioconda::multiqc=1.33' : null)
	container 'quay.io/biocontainers/multiqc:1.33--pyhdfd78af_0'

        input:
        path(files)

        output:
        path "*.html", emit: multiqc_report
	path "multiqc.version", emit: multiqc_version

        script:
        def args = task.ext.args ?: ""

        """
	multiqc --version > multiqc.version
        multiqc . $args $files
        """
}
