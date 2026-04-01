include { QC                      } from "../subworkflows/QC.nf"
include { DOWNSAMPLE_AND_ASSEMBLE } from "../subworkflows/DOWNSAMPLE_AND_ASSEMBLE.nf"
include { ASSEMBLY_QC             } from "../subworkflows/ASSEMBLY_QC.nf"
include { REPORT_DRAFT            } from "../modules/REPORT.nf"

workflow DRAFT_ASSEMBLY {
	// Check input parameters
	if (!params.input) {
                exit 1, "Missing input file."
        }
	if (!params.skip_kraken && !params.kraken_db) {
                exit 1, "Missing Kraken database path."
        }
	if (!params.genome_size) {
                exit 1, "Missing genome size parameter."
        }

        // Channel

	Channel
        .fromPath(params.input, checkIfExists: true)
        .splitCsv(header:true, sep:",")
        .map { tuple(it.id, file(it.R1, checkIfExists: true), file(it.R2, checkIfExists: true)) }
        .set { input_ch }

	// QC
	QC(input_ch)

	// Downsample and assembly
	DOWNSAMPLE_AND_ASSEMBLE(QC.out.trimmed_ch)

	// Assembly QC
	ASSEMBLY_QC(DOWNSAMPLE_AND_ASSEMBLE.out.subsampled_reads,
				DOWNSAMPLE_AND_ASSEMBLE.out.assembly_ch,
				DOWNSAMPLE_AND_ASSEMBLE.out.quast_ch)

	// Collect versions
	all_versions = QC.out.versions
		.mix(DOWNSAMPLE_AND_ASSEMBLE.out.versions)
		.mix(ASSEMBLY_QC.out.versions)
		.collect()

	// Merge and report
	REPORT_DRAFT(ASSEMBLY_QC.out.quast_report,
	             ASSEMBLY_QC.out.coverage_report,
				 all_versions)

	emit:
	ellipsis_ch = DOWNSAMPLE_AND_ASSEMBLE.out.assembly_ch
}
