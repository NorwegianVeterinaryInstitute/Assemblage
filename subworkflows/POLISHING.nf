include { BWA        } from "../modules/BWA.nf"
include { POLYPOLISH } from "../modules/POLYPOLISH.nf"
include { MEDAKA     } from "../modules/MEDAKA.nf"

workflow POLISHING {
	take: 
	assemblies_np
	illumina_reads

	main:
	MEDAKA(assemblies_np)

	illumina_reads
		.join(MEDAKA.out.medaka_consensus_ch, by: 0)
		.set { bwa_input_ch }

	BWA(bwa_input_ch)

    MEDAKA.out.medaka_consensus_ch
		.join(BWA.out.bwa_polypolish_ch, by: 0)
		.set { polypolish_ch }

    POLYPOLISH(polypolish_ch)

	emit:
	polish_out=POLYPOLISH.out.polished_assemblies_ch
}