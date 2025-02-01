process MOB_RECON {
	conda (params.enable_conda ? 'bioconda::mob_suite=3.1.9' : null)
        container 'quay.io/biocontainers/mob_suite:3.1.9--pyhdfd78af_0'

        input:
        tuple val(datasetID), path(assembly), path(db)

        output:
        path "*contig_report.txt", emit: mob_contig_report_ch
	tuple val(datasetID), path("*plasmid*.fasta"), optional: true, emit: mob_plasmid_ch

        script:
        """
	mob_recon --version > mobsuite.version
	mob_recon -i $assembly -p $datasetID -u --debug -n $task.cpus -o results -d $db &> mob_recon.log
	mv results/* .
	"""
}
