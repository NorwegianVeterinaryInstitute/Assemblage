include { BWA        } from "../modules/BWA.nf"
include { POLYPOLISH } from "../modules/POLYPOLISH.nf"

workflow POLISHING {
	take: 
	assemblies
    
	main:
	BWA(assemblies)

    assemblies
		.join(BWA.out.bwa_polypolish_ch, by: 0)
		.set { polypolish_ch }

    POLYPOLISH(polypolish_ch)

	emit:
	
}