include { BWA        } from "../modules/BWA.nf"
include { POLYPOLISH } from "../modules/POLYPOLISH.nf"

workflow POLISHING {
	take: 
	assemblies_reads

	main:

	BWA(assemblies_reads)

	assemblies_reads.map { tuple -> [tuple[0], tuple[-1]] }
		.join(BWA.out.bwa_polypolish_ch, by: 0)
		.set { polypolish_ch }

    POLYPOLISH(polypolish_ch)

	emit:
	polish_out=POLYPOLISH.out.polished_assemblies_ch
}