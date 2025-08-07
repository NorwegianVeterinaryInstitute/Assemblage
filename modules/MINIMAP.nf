process MINIMAP2 {
	conda (params.enable_conda ? 'bioconda::minimap2=2.28' : null)
	container 'quay.io/biocontainers/minimap2:2.28--h577a1d6_4'

        label 'process_high_memory_time'

        input:
        tuple val(datasetID), file(NP), file(ref)

        output:
        file("*")
        tuple val(datasetID), path("${datasetID}_aln.sam"), val("nanopore"), emit: samtools_np_ch
	path "minimap2.version"

	script:
        """
	minimap2 --version > minimap2.version
	minimap2 -ax map-ont $ref $NP > ${datasetID}_aln.sam
        """
}

process MINIMAP2_OVERLAP {
        conda (params.enable_conda ? 'bioconda::minimap2=2.28' : null)
        container 'quay.io/biocontainers/minimap2:2.28--h577a1d6_4'

        label 'process_high_memory_time'

        input:
        tuple val(datasetID), path(NP)

        output:
        file("*")
        tuple val(datasetID), path(NP), path("*_overlap.paf"), emit: minimap_overlap_ch
        path "minimap2.version"

        script:
        """
        fastaname=\$(basename ${NP} | cut -d. -f1)
        minimap2 --version > minimap2.version
        minimap2 -x ava-ont -t $task.cpus $NP $NP > \${fastaname}_overlap.paf
        """
}
