include { QUAST             } from "../modules/QUAST.nf"
include { BWA               } from "../modules/BWA.nf"
include { SAMTOOLS          } from "../modules/SAMTOOLS.nf"
include { BEDTOOLS          } from "../modules/BEDTOOLS.nf"
include { MERGE_COV_REPORTS } from "../modules/MERGE.nf"

workflow ASSEMBLY_QC {
    take:
    downsampled_reads
    assembly_ch
    quast_ch

    main:
    // Generate channel
	downsampled_reads.join(assembly_ch, by: 0)
        .set { mapping_ch }

    // Coverage calculation
	BWA(mapping_ch)
	SAMTOOLS(BWA.out.samtools_bwa_ch)
	BEDTOOLS(SAMTOOLS.out.bam_ch)
	MERGE_COV_REPORTS(BEDTOOLS.out.cov_report_ch.collect())

	// QC
	QUAST(quast_ch.collect())

    emit:
    quast_report = QUAST.out.R_quast
    coverage_report = MERGE_COV_REPORTS.out.coverage_report
}