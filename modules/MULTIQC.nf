process MULTIQC_PRE {
	conda (params.enable_conda ? 'bioconda::multiqc=1.14' : null)
	container 'quay.io/biocontainers/multiqc:1.14--pyhdfd78af_0'

        input:
        file("*")

        output:
        file("*")
	path "multiqc.version"

        """
	multiqc --version > multiqc.version
        multiqc *.zip
        """
}

process MULTIQC_POST {
	conda (params.enable_conda ? 'bioconda::multiqc=1.14' : null)
        container 'quay.io/biocontainers/multiqc:1.14--pyhdfd78af_0'

        input:
        file("*")

        output:
        file("*")

        """
        multiqc *.zip
        """
}
