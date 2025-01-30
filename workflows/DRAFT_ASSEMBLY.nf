include { FASTQC; FASTQC as FASTQC_POST           } from "../modules/FASTQC.nf"
include { MULTIQC_PRE; MULTIQC_POST               } from "../modules/MULTIQC.nf"
include { KRAKEN                                  } from "../modules/KRAKEN.nf"
include { TRIM                                    } from "../modules/TRIM.nf"
include { RASUSA                                  } from "../modules/RASUSA.nf"
include { UNICYCLER                               } from "../modules/UNICYCLER.nf"
include { QUAST                                   } from "../modules/QUAST.nf"
include { BWA                                     } from "../modules/BWA.nf"
include { SAMTOOLS                                } from "../modules/SAMTOOLS.nf"
include { BEDTOOLS                                } from "../modules/BEDTOOLS.nf"
include { MERGE_KRAKEN_REPORTS; MERGE_COV_REPORTS } from "../modules/MERGE.nf"
include { REPORT_DRAFT                            } from "../modules/REPORT.nf"

workflow DRAFT_ASSEMBLY {
        // Channel

	Channel
            .fromPath(params.input, checkIfExists: true)
            .splitCsv(header:true, sep:",")
            .map { tuple(it.id, file(it.R1, checkIfExists: true), file(it.R2, checkIfExists: true)) }
            .set { input_ch }

	Channel
	    .fromPath(params.kraken_db, checkIfExists: true)
	    .set { db_ch }

	input_ch.combine(db_ch)
	    .set { kraken2_input_ch }

	// QC
        FASTQC(input_ch)
        MULTIQC_PRE(FASTQC.out.fastqc_reports.collect())
        KRAKEN(kraken2_input_ch)
	MERGE_KRAKEN_REPORTS(KRAKEN.out.report_ch.collect())
        TRIM(input_ch)
	RASUSA(TRIM.out.trim_reads)
        FASTQC_POST(RASUSA.out.subsampled_reads)
        MULTIQC_POST(FASTQC_POST.out.fastqc_reports.collect())

	// Assembly
	UNICYCLER(RASUSA.out.subsampled_reads)

	// Generate channel
	RASUSA.out.subsampled_reads.join(UNICYCLER.out.assembly_ch, by: 0)
             .set { mapping_ch }

	// Coverage calculation
	BWA(mapping_ch)
	SAMTOOLS(BWA.out.samtools_bwa_ch)
	BEDTOOLS(SAMTOOLS.out.bam_ch)
	MERGE_COV_REPORTS(BEDTOOLS.out.cov_report_ch.collect())

	// QC
	QUAST(UNICYCLER.out.quast_ch.collect())

	// Merge and report

	REPORT_DRAFT(QUAST.out.R_quast,
	             MERGE_KRAKEN_REPORTS.out.kraken_report,
	             MERGE_COV_REPORTS.out.coverage_report)

	emit:
	ellipsis_ch = UNICYCLER.out.assembly_ch
}
