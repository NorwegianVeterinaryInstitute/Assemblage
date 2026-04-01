include { QUAST             } from "../modules/QUAST.nf"
include { BWA               } from "../modules/BWA.nf"
include { SAMTOOLS          } from "../modules/SAMTOOLS.nf"
include { BEDTOOLS          } from "../modules/BEDTOOLS.nf"
include { MERGE_COV_REPORTS } from "../modules/MERGE.nf"
include { CHECKM2           } from "../modules/CHECKM.nf"

workflow ASSEMBLY_QC {
    take:
    il_downsampled_reads
    assembly_ch
    quast_ch

    main:
    // Generate channel
	il_downsampled_reads.join(assembly_ch, by: 0)
        .set { mapping_ch }

    // Coverage calculation
	BWA(mapping_ch)

	SAMTOOLS(BWA.out.samtools_bwa_ch)
	BEDTOOLS(SAMTOOLS.out.bam_ch)
	MERGE_COV_REPORTS(BEDTOOLS.out.il_cov_report_ch.collect())

	// QC
	QUAST(quast_ch.collect())
	// CHECKM2(assembly_ch.map { id, fasta -> fasta }.collect())

    emit:
    quast_report = QUAST.out.R_quast
    coverage_report = MERGE_COV_REPORTS.out.coverage_report
    // completeness_report = CHECKM2.out.checkm2_ch
    versions = BWA.out.bwa_version.first()
        .mix(SAMTOOLS.out.samtools_version.first())
        .mix(BEDTOOLS.out.bedtools_version.first())
        .mix(QUAST.out.quast_version.first())
        .collect()
}