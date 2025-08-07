include { FASTQC; FASTQC as FASTQC_POST                   } from "../modules/FASTQC.nf"
include { MULTIQC as MULTIQC_PRE; MULTIQC as MULTIQC_POST } from "../modules/MULTIQC.nf"
include { KRAKEN                                          } from "../modules/KRAKEN.nf"
include { TRIM                                            } from "../modules/TRIM.nf"

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
        KRAKEN(kraken2_input_ch)
        MERGE_KRAKEN_REPORTS(KRAKEN.out.report_ch.collect())
    }

    emit:
    trimmed_ch=TRIM.out.trim_reads
}