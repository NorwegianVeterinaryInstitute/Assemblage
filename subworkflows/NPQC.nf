include { FILTLONG } from "../modules/FILTLONG.nf"

workflow NPQC {
	take: 
	reads

	main:
	FILTLONG(reads)

	emit:
	reads=FILTLONG.out.filtlong_ch
}
