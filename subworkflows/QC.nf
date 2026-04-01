include { FASTQC; FASTQC as FASTQC_POST } from "../modules/FASTQC.nf"
include { MULTIQC as MULTIQC_PRE        } from "../modules/MULTIQC.nf"
include { MULTIQC as MULTIQC_POST       } from "../modules/MULTIQC.nf"
include { MULTIQC as MULTIQC_KRAKEN     } from "../modules/MULTIQC.nf"
include { KRAKEN                        } from "../modules/KRAKEN.nf"
include { MERGE_KRAKEN_REPORTS          } from "../modules/MERGE.nf"
include { TRIM                          } from "../modules/TRIM.nf"

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
        MULTIQC_KRAKEN(KRAKEN.out.report_ch.collect())
    }

    emit:
    trimmed_ch=TRIM.out.trim_reads
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