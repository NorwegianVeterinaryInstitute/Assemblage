process TRIM {
	conda (params.enable_conda ? 'bioconda::trim-galore=0.6.10' : null)
	container 'quay.io/biocontainers/trim-galore:0.6.10--hdfd78af_0'

        input:
        tuple val(datasetID), file(R1), file(R2)

        output:
        file("*")
        tuple val(datasetID), path {"*val_1.fq.gz"}, path {"*val_2.fq.gz"}, emit: trim_reads

        script:
        """
        trim_galore -o . --paired --quality $params.phred_score -e $params.error_rate --length $params.minlength $R1 $R2 &> ${datasetID}_trimgalore.log
        """
}
