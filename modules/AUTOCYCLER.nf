process AUTOCYCLER_SUBSET {
	conda (params.enable_conda ? 'bioconda::autocycler=0.2.1' : null)
	container 'evezeyl/autocycler:0.2.1'

    input:
    tuple val(datasetID), path(reads)

    output:
	path "autocycler.version"
	tuple val(datasetID), path("*sample_*"), emit: sub_ch

	script:
	"""
	autocycler --version > autocycler.version
	autocycler subsample --reads $reads --out_dir . --genome_size $params.genome_size --count 12 --min_read_depth $params.min_read_depth
	ls sample_*.fastq | xargs -I {} mv {} ${datasetID}_{}
	"""
}

process AUTOCYCLER_COMPRESS {
	conda (params.enable_conda ? 'bioconda::autocycler=0.2.1' : null)
	container 'evezeyl/autocycler:0.2.1'

    input:
    tuple val(datasetID), path(canu_asmbl), path(flye_asmbl), path(raven_asmbl), path(miniasm_asmbl)

    output:
	tuple val(datasetID), path("input_assemblies.gfa"), emit: compress_ch

	"""
	autocycler compress -i . -a results --kmer $params.autocycler_kmer --max_contigs $params.autocycler_n_contigs --threads $task.cpus
	cp results/input_assemblies.gfa .
	"""
}

process AUTOCYCLER_CLUSTER {
	conda (params.enable_conda ? 'bioconda::autocycler=0.2.1' : null)
	container 'evezeyl/autocycler:0.2.1'

	label 'process_high_memory_time'

    input:
    tuple val(datasetID), path(gfa)

    output:

	"""
	autocycler cluster --cutoff $params.autocycler_cutoff --max_contigs $params.autocycler_n_contigs --min_assemblies $params.autocycler_min_assemblies -a . 
	"""
}

process AUTOCYCLER_TRIM {
	conda (params.enable_conda ? 'bioconda::autocycler=0.2.1' : null)
	container 'evezeyl/autocycler:0.2.1'

    input:
    tuple val(datasetID), path(gfa)

    output:

	"""
	autocycler trim --min_identity $params.autocycler_identity --max_unitigs $params.autocycler_max_unitigs --mad $params.autocycler_mad --threads $task.cpus -a . 
	"""
}