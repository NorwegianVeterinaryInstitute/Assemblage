include { FASTQC           } from "../modules/FASTQC.nf"
include { MULTIQC_PRE      } from "../modules/MULTIQC.nf"
include { KRAKEN           } from "../modules/KRAKEN.nf"
include { RASUSA           } from "../modules/RASUSA.nf"
include { FILTLONG         } from "../modules/FILTLONG.nf"
include { UNICYCLER_HYBRID } from "../modules/UNICYCLER.nf"
include { QUAST_COMPARE    } from "../modules/QUAST.nf"
include { BWA              } from "../modules/BWA.nf"
include { SAMTOOLS         } from "../modules/SAMTOOLS.nf"
include { BEDTOOLS         } from "../modules/BEDTOOLS.nf"
include { POLYPOLISH       } from "../modules/POLYPOLISH.nf"
include { MINIMAP2         } from "../modules/MINIMAP.nf"
include { MERGE_REPORTS    } from "../modules/MERGE.nf"
include { REPORT_HYBRID    } from "../modules/REPORT.nf"

workflow HYBRID_ASSEMBLY {
	// Check input parameters
	if (!params.input) {
                exit 1, "Missing input file."
        }
	if (!params.genome_size) {
                exit 1, "Missing genome size parameter."
        }
	if (!params.kraken_db) {
                exit 1, "Missing kraken database path."
        }

	// Channels
	Channel
            .fromPath(params.input, checkIfExists: true)
            .splitCsv(header:true, sep:",")
            .map { tuple(it.id, file(it.R1, checkIfExists: true), file(it.R2, checkIfExists: true), file(it.np, checkIfExists: true)) }
            .set { input_ch }

	input_ch
                .map { id, R1, R2, np ->
                        tuple( id, R1, R2 )
                }
                .set { illumina_ch }

        input_ch
                .map { id, R1, R2, np ->
                        tuple( id, np )
                }
                .set { nanopore_ch }

	Channel
            .fromPath(params.kraken_db, checkIfExists: true)
            .set { db_ch }

        illumina_ch.combine(db_ch)
            .set { kraken2_input_ch }

	// Quality control
	FASTQC(illumina_ch)
        MULTIQC_PRE(FASTQC.out.fastqc_reports.collect())
        KRAKEN(kraken2_input_ch)
        RASUSA(illumina_ch)

	// Read filtering
	FILTLONG(nanopore_ch)

	RASUSA.out.subsampled_reads.join(FILTLONG.out.filtlong_ch, by: 0)
		.set { assembly_ch }

	// Assembly
	UNICYCLER_HYBRID(assembly_ch)

	// Coverage calculation
	RASUSA.out.subsampled_reads
	        .join(UNICYCLER_HYBRID.out.assemblies_ch, by: 0)
		.set { mapping_ch }

	FILTLONG.out.filtlong_ch
	        .join(UNICYCLER_HYBRID.out.assemblies_ch, by: 0)
		.set { np_mapping_ch }

	BWA(mapping_ch)
	MINIMAP2(np_mapping_ch)

	BWA.out.samtools_bwa_ch
		.concat(MINIMAP2.out.samtools_np_ch)
		.set { samtools_ch }


	SAMTOOLS(samtools_ch)
	BEDTOOLS(SAMTOOLS.out.bam_ch)

	// Polishing
	UNICYCLER_HYBRID.out.assemblies_ch
		.join(BWA.out.bwa_polypolish_ch, by: 0)
		.set { polypolish_ch }

	POLYPOLISH(polypolish_ch)

	UNICYCLER_HYBRID.out.assemblies_ch
		.join(POLYPOLISH.out.polished_assemblies_ch, by: 0)
		.set { quast_compare_ch }

	QUAST_COMPARE(quast_compare_ch)

	// Merge reports
	MERGE_REPORTS(QUAST_COMPARE.out.quast_compare_ch.collect(),
		      UNICYCLER_HYBRID.out.r_contig_names_ch.collect(),
		      BEDTOOLS.out.cov_report_ch.collect(),
                      KRAKEN.out.report_ch.collect())

	// Reporting
	REPORT_HYBRID(MERGE_REPORTS.out.quast_report_ch,
		      MERGE_REPORTS.out.completeness_report_ch,
		      MERGE_REPORTS.out.il_coverage_report_ch,
		      MERGE_REPORTS.out.np_coverage_report_ch,
	              MERGE_REPORTS.out.kraken_report_ch)

	emit:
	ellipsis_ch = POLYPOLISH.out.polished_assemblies_ch
}
