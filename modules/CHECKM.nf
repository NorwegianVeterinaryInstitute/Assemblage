process CHECKM2 {
    conda (params.enable_conda ? 'bioconda::checkm2=1.0.2' : null)
	container 'quay.io/biocontainers/checkm2:1.0.2--pyh7cba7a3_0'

    tag "batch_${batch_id}"

    input:
    tuple val(batch_id), path(genomes), path(checkm_db)

    output:
    tuple val(batch_id), path("checkm2_batch_${batch_id}_out"), emit: checkm2_ch
    path("checkm2.version"), emit: checkm2_version

    script:
    """
    mkdir bins
    for genome in ${genomes}; do
        cp \$genome bins/
    done
    
    checkm2 --version > checkm2.version
    checkm2 predict --input bins --threads $task.cpus --output-directory checkm2_batch_${batch_id}_out --database_path $checkm_db -x fasta
    """
}