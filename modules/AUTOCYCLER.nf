process AUTOCYCLER_SUBSET {
	conda (params.enable_conda ? 'bioconda::autocycler=0.2.1' : null)
	container 'evezeyl/autocycler:0.2.1'

    input:
    tuple val(datasetID), path(reads)

    output:
	path "autocycler.version"
	tuple val(datasetID), path("sample_*"), emit: sub_ch

	"""
	autocycler --version > autocycler.version
	autocycler subsample --reads $reads --out_dir . --genome_size $params.genome_size --count 12 --min_read_depth $params.min_read_depth
	"""
}

process AUTOCYCLER_COMPRESS {
	conda (params.enable_conda ? 'bioconda::autocycler=0.2.1' : null)
	container 'evezeyl/autocycler:0.2.1'

    input:
    tuple val(datasetID), path(canu_asmbl), path(flye_asmbl), path(raven_asmbl), path(miniasm_asmbl)

    output:
	tuple val(datasetID), path("${datasetID}_compressed.gfa"), emit: compress_ch

	"""
	mkdir assemblies
	mv *fasta assemblies
	autocycler compress -i assemblies -a results --kmer $params.autocycler_kmer --max_contigs $params.autocycler_n_contigs --threads $task.cpus
	cp results/input_assemblies.gfa ${datasetID}_compressed.gfa 
	"""
}