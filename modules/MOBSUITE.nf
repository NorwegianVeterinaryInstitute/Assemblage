process MOB_RECON {
	conda (params.enable_conda ? 'bioconda::mob_suite=3.1.9' : null)
        container 'quay.io/biocontainers/mob_suite:3.1.9--pyhdfd78af_0'

        input:
        tuple val(datasetID), path(assembly), path(db)

        output:
        path "*contig_report.txt", emit: mobsuite_out_ch
	path "*plasmid*.fasta", optional: true
	path "*mge_report.txt"
	path "*chromosome.fasta"
	path "mobsuite.version"

        script:
        """
	mob_recon --version > mobsuite.version
	mob_recon -i $assembly -p $datasetID -u --debug -n $task.cpus -o results -d $db &> mob_recon.log
	mv results/* .
	"""
}
