process AMRFINDERPLUS {
	conda (params.enable_conda ? 'bioconda::ncbi-amrfinderplus=4.0.15' : null)
	container 'quay.io/biocontainers/ncbi-amrfinderplus:4.0.15--hf69ffd2_0'

        input:
        tuple val(datasetID), path (replicon), path(db)

        output:
	file("*")

        script:
        """
        amrfinder --database_version > amrfinderplus.version
	amrfinder -n $replicon --database $db --threads $task.cpus --organism $params.amrfinder_organism  
        """
}
