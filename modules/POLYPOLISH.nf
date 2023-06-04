process POLYPOLISH {
	conda (params.enable_conda ? 'bioconda::polypolish=0.5.0' : null)
	container 'quay.io/biocontainers/polypolish:0.5.0--hdbdd923_4'

        input:
        tuple val(datasetID), file(R1), file(R2), file(assembly)

        output:
        file("*")
	file("${datasetID}_filtered.fasta"), emit: polypolish_assembly

        """
	bwa index $assembly
	bwa mem -t $task.cpus -a $assembly $R1 > alignments1.sam
	bwa mem -t $task.cpus -a $assembly $R2 > alignments2.sam
	polypolish_insert_filter.py --in1 alignments_1.sam --in2 alignments_2.sam --out1 filtered_1.sam --out2 filtered_2.sam
	polypolish $assembly filtered_1.sam filtered_2.sam > ${datasetID}_filtered.fasta
	"""
}
