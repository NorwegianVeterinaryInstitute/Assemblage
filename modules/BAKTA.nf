process BAKTA {
	conda (params.enable_conda ? 'bioconda::bakta=1.9.1' : null)
	container 'evezeyl/bakta:1.9.1'

        input:
        tuple val(datasetID), path (assembly), path(db)

        output:
        tuple val(datasetID), path("*.gff3"), emit: bakta_ch
        path("*.txt"), emit: bakta_txt_ch
	path "bakta.version", emit: bakta_version

        script:
        """
        mkdir -p tmp
        export TMPDIR=\$PWD/tmp
        export TMP=\$PWD/tmp

        bakta --version > bakta.version
        bakta --db $db --skip-plot --prefix $assembly.baseName --threads $task.cpus $assembly
        """
}
