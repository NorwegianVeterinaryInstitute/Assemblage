include { FASTQC; FASTQC as FASTQC_POST                   } from "../modules/FASTQC.nf"
include { MULTIQC as MULTIQC_PRE; MULTIQC as MULTIQC_POST } from "../modules/MULTIQC.nf"
include { KRAKEN                                          } from "../modules/KRAKEN.nf"
include { MERGE_KRAKEN_REPORTS                            } from "../modules/MERGE.nf"
include { TRIM                                            } from "../modules/TRIM.nf"
include { REPORT_KRAKEN                                   } from "../modules/REPORT.nf"

workflow QC {
    take:
    input_ch

    main:
    FASTQC(input_ch)
    MULTIQC_PRE(FASTQC.out.fastqc_reports.collect())
    TRIM(input_ch)
	FASTQC_POST(TRIM.out.trim_reads)
    MULTIQC_POST(FASTQC_POST.out.fastqc_reports.collect())

    if(!params.skip_kraken) {

        Channel
	        .fromPath(params.kraken_db, checkIfExists: true)
	        .set { db_ch }

        input_ch.combine(db_ch)
	        .set { kraken2_input_ch }

        KRAKEN(kraken2_input_ch)
        MERGE_KRAKEN_REPORTS(KRAKEN.out.report_ch.collect())
        REPORT_KRAKEN(MERGE_KRAKEN_REPORTS.out.kraken_report, "short")
    }

    emit:
    trimmed_ch=TRIM.out.trim_reads
}