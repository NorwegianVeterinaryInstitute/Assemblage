process SPADES {
    conda (params.enable_conda ? 'bioconda::spades=4.2.0' : null)
    container 'quay.io/biocontainers/spades:4.2.0--h8d6e82b_2'

    label 'process_high_memory_time'

    input:
    tuple val(datasetID), path(R1), path(R2)

    output:
    path("${datasetID}.fasta"), emit: quast_ch
    tuple val(datasetID), path("${datasetID}.fasta"), emit: assembly_ch
    path "spades.version", emit: spades_version

    script:
    def args = task.ext.args ?: ''

    """
    spades.py --version > spades.version 2>&1
    spades.py \\
        -1 $R1 -2 $R2 \\
        -t $task.cpus \\
        -o spades \\
        $args

    if [ -s spades/scaffolds.fasta ]; then
        cp spades/scaffolds.fasta ${datasetID}.fasta
    else
        cp spades/contigs.fasta ${datasetID}.fasta
    fi

    sed -i 's/ /_/g' ${datasetID}.fasta
    """
}

process SPADES_HYBRID {
    conda (params.enable_conda ? 'bioconda::spades=4.2.0' : null)
    container 'quay.io/biocontainers/spades:4.2.0--h8d6e82b_2'

    label 'process_high_memory_time'

    input:
    tuple val(datasetID), path(R1), path(R2), path(np)

    output:
    path("${datasetID}.fasta"), emit: quast_ch
    tuple val(datasetID), path("${datasetID}.fasta"), emit: assemblies_ch
    path "spades.version", emit: spades_version

    script:
    def args = task.ext.args ?: ''

    """
    spades.py --version > spades.version 2>&1
    spades.py \\
        -1 $R1 -2 $R2 \\
        --nanopore $np \\
        -t $task.cpus \\
        -o spades \\
        $args

    if [ -s spades/scaffolds.fasta ]; then
        cp spades/scaffolds.fasta ${datasetID}.fasta
    else
        cp spades/contigs.fasta ${datasetID}.fasta
    fi

    sed -i 's/ /_/g' ${datasetID}.fasta
    grep ">" ${datasetID}.fasta > ${datasetID}_contig_names.txt
    """
}