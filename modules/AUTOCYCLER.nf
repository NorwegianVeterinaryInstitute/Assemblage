process AUTOCYCLER_SUBSET {
	conda (params.enable_conda ? 'bioconda::autocycler=0.4.0' : null)
	container 'quay.io/biocontainers/autocycler:0.4.0--h3ab6199_0'

    input:
    tuple val(datasetID), path(reads)

    output:
	path "autocycler.version"
	tuple val(datasetID), path("*sample_*"), emit: sub_ch
	tuple val(datasetID), path("subsample.yaml"), emit: subsample_yaml_ch

	script:
	"""
	autocycler --version > autocycler.version
	autocycler subsample --reads $reads --out_dir . --genome_size $params.genome_size --count 12 --min_read_depth $params.min_read_depth
	ls sample_*.fastq | xargs -I {} mv {} ${datasetID}_{}
	"""
}

process AUTOCYCLER_COMPRESS {
	conda (params.enable_conda ? 'bioconda::autocycler=0.4.0' : null)
	container 'quay.io/biocontainers/autocycler:0.4.0--h3ab6199_0'

    input:
    tuple val(datasetID), path(canu_asmbl), path(flye_asmbl), path(raven_asmbl), path(miniasm_asmbl)

    output:
	tuple val(datasetID), path("input_assemblies.gfa"), emit: compress_ch
	tuple val(datasetID), path("input_assemblies.yaml"), emit: compress_yaml_ch

	"""
	autocycler compress -i . -a results --kmer $params.autocycler_kmer --max_contigs $params.autocycler_n_contigs --threads $task.cpus
	cp results/input_assemblies.gfa .
	cp results/input_assemblies.yaml .
	"""
}

process AUTOCYCLER_CLUSTER {
	conda (params.enable_conda ? 'bioconda::autocycler=0.4.0' : null)
	container 'quay.io/biocontainers/autocycler:0.4.0--h3ab6199_0'

	label 'process_high_memory_time'

    input:
    tuple val(datasetID), path(gfa)

    output:
	tuple val(datasetID), path("clustering/qc_pass/cluster*", type: 'dir'), emit: cluster_ch
	tuple val(datasetID), path("clustering.yaml"), emit: clustering_yaml_ch

	"""
	autocycler cluster --cutoff $params.autocycler_cutoff --max_contigs $params.autocycler_n_contigs --min_assemblies $params.autocycler_min_assemblies -a . 
	cp clustering/clustering.yaml .
	"""
}

process AUTOCYCLER_TRIM {
	conda (params.enable_conda ? 'bioconda::autocycler=0.4.0' : null)
	container 'quay.io/biocontainers/autocycler:0.4.0--h3ab6199_0'

    input:
    tuple val(datasetID), val(cluster), path(files)

    output:
	tuple val(datasetID), val(cluster), path("2_*"), emit: trim_ch
	tuple val(datasetID), val(cluster), path("1_untrimmed.gfa"), path("2_trimmed.gfa"), emit: dotplot_ch
	tuple val(datasetID), path("${cluster}_2_trimmed.yaml"), emit: trimming_yaml_ch

	"""
	autocycler trim --min_identity $params.autocycler_identity --max_unitigs $params.autocycler_max_unitigs --mad $params.autocycler_mad --threads $task.cpus -c .
	cp 2_trimmed.yaml ${cluster}_2_trimmed.yaml
	"""
}

process AUTOCYCLER_DOTPLOT {
	conda (params.enable_conda ? 'bioconda::autocycler=0.4.0' : null)
	container 'quay.io/biocontainers/autocycler:0.4.0--h3ab6199_0'

    input:
    tuple val(datasetID), val(cluster), path(untrimmed), path(trimmed)

    output:
	path("*.png")

	"""
	autocycler dotplot -i $untrimmed -o ${datasetID}_${cluster}_untrimmed.png
	autocycler dotplot -i $trimmed -o ${datasetID}_${cluster}_trimmed.png
	"""
}

process AUTOCYCLER_RESOLVE {
	conda (params.enable_conda ? 'bioconda::autocycler=0.4.0' : null)
	container 'quay.io/biocontainers/autocycler:0.4.0--h3ab6199_0'

    input:
    tuple val(datasetID), val(cluster), path(files)

    output:
	tuple val(datasetID), path("*final.gfa"), emit: resolve_ch

	"""
	autocycler resolve -c .
	mv 5_final.gfa 5_${cluster}_final.gfa
	"""
}

process AUTOCYCLER_COMBINE {
	conda (params.enable_conda ? 'bioconda::autocycler=0.4.0' : null)
	container 'quay.io/biocontainers/autocycler:0.4.0--h3ab6199_0'

    input:
    tuple val(datasetID), path(gfa)

    output:
	path("${datasetID}_consensus_assembly.fasta"), emit: assemblies_ch
	tuple val(datasetID), path("consensus_assembly.yaml"), emit: combine_yaml_ch

	"""
	autocycler combine --autocycler_dir . --in_gfas $gfa
	mv consensus_assembly.fasta ${datasetID}_consensus_assembly.fasta
	"""
}

process AUTOCYCLER_TABLE {
	conda (params.enable_conda ? 'bioconda::autocycler=0.4.0' : null)
	container 'quay.io/biocontainers/autocycler:0.4.0--h3ab6199_0'

    input:
    tuple val(datasetID), path(yaml)

    output:
	path("${datasetID}_metrics.tsv")

	"""
	autocycler table > ${datasetID}_metrics.tsv
	autocycler table --autocycler_dir . -n $datasetID >> ${datasetID}_metrics.tsv
	"""
}