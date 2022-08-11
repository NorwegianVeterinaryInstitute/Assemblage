process PILON {
	publishDir "${params.out_dir}/02_ASSEMBLY/04_polished_genomes", pattern: "${datasetID}_pilon.fasta", mode: "copy"

        tag "$datasetID"

        input:
        tuple val(datasetID), file(fasta), file(bam)

        output:
	path("${datasetID}_pilon.fasta"), emit: quast_ch

        """
	export _JAVA_OPTIONS="-Xms512M -Xmx2G"
	pilon --genome $fasta --bam $bam --output ${datasetID}_pilon --changes --vcfqe
        """
}
