include { BWA                 } from "../modules/BWA.nf"
include { POLYPOLISH          } from "../modules/POLYPOLISH.nf"
include { QUAST_COMPARE       } from "../modules/QUAST.nf"
include { MERGE_QUAST_REPORTS } from "../modules/MERGE.nf"

workflow POLISHING {
	take: 
	assemblies_reads

	main:

	BWA(assemblies_reads)

	assemblies_reads.map { tuple -> [tuple[0], tuple[-1]] }
		.join(BWA.out.bwa_polypolish_ch, by: 0)
		.set { polypolish_ch }

    POLYPOLISH(polypolish_ch)

	polypolish_ch.map { tuple -> [tuple[0], tuple[1]] }
		.join(POLYPOLISH.out.polished_assemblies_ch, by: 0)
		.set { quast_ch }

	QUAST_COMPARE(quast_ch)

	emit:
	polish_out=POLYPOLISH.out.polished_assemblies_ch
	quast_compare_out=QUAST_COMPARE.out.quast_compare_ch
	versions = BWA.out.bwa_version
		.mix(POLYPOLISH.out.polypolish_version)
		.mix(QUAST_COMPARE.out.quast_compare_version)
		.collect()
}