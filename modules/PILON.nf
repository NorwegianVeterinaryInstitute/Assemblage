process PILON {
	publishDir "${params.out_dir}/02_ASSEMBLY/05_polished_genomes", pattern: "${datasetID}_pilon.fasta", mode: "copy"

        tag "$datasetID"

        input:
        tuple val(datasetID), file(fasta), file(bam)

        output:
	file("${datasetID}_pilon.fasta")

        """
	export _JAVA_OPTIONS="-Xms512M -Xmx2G"
	pilon --threads $task.cpus --genome $fasta --bam $bam --output ${datasetID}_pilon --changes --vcfqe
        """
}
