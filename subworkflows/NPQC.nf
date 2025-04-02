include { FASTPLONG } from "../modules/FASTP.nf"
include { MULTIQC   } from "../modules/MULTIQC.nf"

workflow NPQC {
	take: 
	reads

	main:
	FASTPLONG(reads)
	//MULTIQC(FASTPLONG.out.fastplong_ch.collect())

	emit:
	reads=FASTPLONG.out.fastplong_ch
}
