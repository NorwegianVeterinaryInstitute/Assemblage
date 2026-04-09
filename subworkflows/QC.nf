include { FASTQC; FASTQC as FASTQC_POST } from "../modules/FASTQC.nf"
include { KRAKEN                        } from "../modules/KRAKEN.nf"
include { TRIM                          } from "../modules/TRIM.nf"

workflow QC {
    take:
    input_ch

    main:
    FASTQC(input_ch)
    TRIM(input_ch)
	FASTQC_POST(TRIM.out.trim_reads)

    if(!params.skip_kraken) {

        Channel
	        .fromPath(params.kraken_db, checkIfExists: true)
	        .set { db_ch }

        input_ch.combine(db_ch)
	        .set { kraken2_input_ch }

        KRAKEN(kraken2_input_ch)
    }

    emit:
    trimmed_ch=TRIM.out.trim_reads
    fastqc_pre_ch=FASTQC.out.fastqc_reports
    fastqc_post_ch=FASTQC_POST.out.fastqc_reports
    kraken_report_ch = params.skip_kraken ? Channel.empty() : KRAKEN.out.report_ch
    versions = FASTQC.out.fastqc_version
        .mix(TRIM.out.trim_galore_version)
        .mix(params.skip_kraken ? Channel.empty() : KRAKEN.out.kraken2_version)
        .collect()
        .map { files ->
            files
                .groupBy { it.name }
                .collect { name, group -> group[0] }
        }
}