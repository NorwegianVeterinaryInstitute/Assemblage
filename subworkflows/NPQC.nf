include { FILTLONG    } from "../modules/FILTLONG.nf"
include { KRAKEN_LONG } from "../modules/KRAKEN.nf"

workflow NPQC {
	take: 
	reads

	main:
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
	}

	emit:
	reads=FILTLONG.out.filtlong_ch
	kraken_long_report_ch = params.skip_kraken ? Channel.empty() : KRAKEN_LONG.out.long_report_ch
	versions = FILTLONG.out.filtlong_version
		.mix(params.skip_kraken ? Channel.empty() : KRAKEN_LONG.out.kraken2_version)
		.collect()
		.map { files ->
            files
                .groupBy { it.name }
                .collect { name, group -> group[0] }
        }
}
