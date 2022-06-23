process BWA {
        publishDir "${params.out_dir}/results/mapping/", pattern: "*.bam", mode: "copy"

        tag "$datasetID"
        label 'bigmem'

        input:
        tuple val(datasetID), file(R1), file(R2), file(ref)

        output:
        file("*")
        path "*.fasta", emit: quast_ch

        """
	bwa index $ref
	bwa mem -t $task.cpus $ref $R1 $R2 > ${datasetID}.bam
        """
}

