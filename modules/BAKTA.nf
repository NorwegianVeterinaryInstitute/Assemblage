process BAKTA {
	conda (params.enable_conda ? 'bioconda::bakta=1.9.1' : null)
	container 'evezeyl/bakta:1.9.1'

        input:
        tuple val(datasetID), path (assembly), path(db)

        output:
        path "*.gff3", emit: bakta_ch
	path "bakta.version"

        script:
        """
        bakta --version > bakta.version
        bakta --db $db --skip-plot --prefix $assembly.baseName --threads $task.cpus $assembly
        """
}
