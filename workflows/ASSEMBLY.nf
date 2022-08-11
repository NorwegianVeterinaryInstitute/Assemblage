include { UNICYCLER } from "${params.module_dir}/UNICYCLER.nf"
include { QUAST } from "${params.module_dir}/QUAST.nf"
include { BWA } from "${params.module_dir}/BWA.nf"
include { SAMTOOLS } from "${params.module_dir}/SAMTOOLS.nf"
include { BEDTOOLS } from "${params.module_dir}/BEDTOOLS.nf"

workflow ASSEMBLY {
        // Channel
        Channel
                .fromFilePairs(params.reads, flat: true, checkIfExists: true)
                .set { reads_ch }

	// Assembly
	UNICYCLER(reads_ch)
	QUAST(UNICYCLER.out.quast_ch.collect())

	// Generate channel
	reads_ch.join(UNICYCLER.out.assembly_ch, by: 0)
		.set { mapping_ch }

	// Coverage calculation
	BWA(mapping_ch)
	SAMTOOLS(BWA.out.samtools_ch)
	BEDTOOLS(SAMTOOLS.out.bam_ch)
}
