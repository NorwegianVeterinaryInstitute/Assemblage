process AUTOCYCLER_SUBSET {
	conda (params.enable_conda ? 'bioconda::autocycler=0.6.1' : null)
	container 'quay.io/staphb/autocycler:0.6.1'

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
	conda (params.enable_conda ? 'bioconda::autocycler=0.6.1' : null)
	container 'quay.io/staphb/autocycler:0.6.1'

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
	conda (params.enable_conda ? 'bioconda::autocycler=0.6.1' : null)
	container 'quay.io/staphb/autocycler:0.6.1'

	label 'process_high_memory_time'

    input:
    tuple val(datasetID), path(gfa)

    output:
	tuple val(datasetID), path("clustering/qc_pass/cluster*", type: 'dir'), emit: cluster_ch
	tuple val(datasetID), path("clustering.yaml"), emit: clustering_yaml_ch
	path "*_clustering.newick"

	"""
	autocycler cluster --cutoff $params.autocycler_cutoff --max_contigs $params.autocycler_n_contigs --min_assemblies $params.autocycler_min_assemblies -a . 
	cp clustering/clustering.yaml .
	cp clustering/clustering.newick ${datasetID}_clustering.newick
	"""
}

process AUTOCYCLER_TRIM {
	conda (params.enable_conda ? 'bioconda::autocycler=0.6.1' : null)
	container 'quay.io/staphb/autocycler:0.6.1'

    input:
    tuple val(datasetID), val(cluster), path(files)

    output:
	tuple val(datasetID), val(cluster), path("2_*"), emit: trim_ch
	tuple val(datasetID), path("2_trimmed.yaml"), emit: trimming_yaml_ch
	tuple val(datasetID), path("1_untrimmed.yaml"), emit: untrimmed_yaml_ch

	"""
	autocycler trim --min_identity $params.autocycler_identity --max_unitigs $params.autocycler_max_unitigs --mad $params.autocycler_mad --threads $task.cpus -c .

	"""
}

process AUTOCYCLER_RESOLVE {
	conda (params.enable_conda ? 'bioconda::autocycler=0.6.1' : null)
	container 'quay.io/staphb/autocycler:0.6.1'

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
	conda (params.enable_conda ? 'bioconda::autocycler=0.6.1' : null)
	container 'quay.io/staphb/autocycler:0.6.1'

    input:
    tuple val(datasetID), path(gfa)

    output:
	tuple val(datasetID), path("${datasetID}_consensus_assembly.gfa"), emit: assemblies_gfa_ch
	tuple val(datasetID), path("consensus_assembly.yaml"), emit: combine_yaml_ch

	"""
	autocycler combine --autocycler_dir . --in_gfas $gfa
	mv consensus_assembly.gfa ${datasetID}_consensus_assembly.gfa
	"""
}

process AUTOCYCLER_TABLE {
	conda (params.enable_conda ? 'bioconda::autocycler=0.6.1' : null)
	container 'quay.io/staphb/autocycler:0.6.1'

    input:
    tuple val(datasetID), path(yaml)

    output:
	path("${datasetID}_metrics.tsv")

	"""
	autocycler table > ${datasetID}_metrics.tsv
	autocycler table --autocycler_dir . -n $datasetID >> ${datasetID}_metrics.tsv
	"""
}

process AUTOCYCLER_GFA2FASTA {
	conda (params.enable_conda ? 'bioconda::autocycler=0.6.1' : null)
	container 'quay.io/staphb/autocycler:0.6.1'

    input:
    tuple val(datasetID), path(gfa)

    output:
	tuple val(datasetID), path("${datasetID}_consensus_assembly.fasta"), emit: consensus_assembly_ch

	"""
	autocycler gfa2fasta -i $gfa -o ${datasetID}_consensus_assembly.fasta
	"""
}