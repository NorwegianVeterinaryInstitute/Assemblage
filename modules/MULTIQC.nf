process MULTIQC {
	conda (params.enable_conda ? 'bioconda::multiqc=1.14' : null)
	container 'quay.io/biocontainers/multiqc:1.14--pyhdfd78af_0'

        input:
        path(files)

        output:
        file("*")
	path "multiqc.version"

        """
	multiqc --version > multiqc.version
        multiqc $files
        """
}
