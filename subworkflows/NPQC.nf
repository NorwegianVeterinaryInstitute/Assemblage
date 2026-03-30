include { FILTLONG    } from "../modules/FILTLONG.nf"
include { NANOPLOT    } from "../modules/NANOPLOT.nf"
include { KRAKEN_LONG } from "../modules/KRAKEN.nf"

workflow NPQC {
	take: 
	reads

	main:
	NANOPLOT(reads)
	FILTLONG(reads)

	if (!params.skip_kraken) {
		if (!params.kraken_db) {
        	exit 1, "Missing kraken database path."
    	}

		Channel
    	.fromPath(params.kraken_db, checkIfExists: true)
    		.set { db_ch }

		reads
     		.combine(db_ch)
     		.set { kraken2_input_ch }

		KRAKEN_LONG(kraken2_input_ch)
		MERGE_KRAKEN_REPORTS(KRAKEN_LONG.out.long_report_ch.collect())
        REPORT_KRAKEN(MERGE_KRAKEN_REPORTS.out.kraken_report, "long_read")
	}

	emit:
	reads=FILTLONG.out.filtlong_ch
}
