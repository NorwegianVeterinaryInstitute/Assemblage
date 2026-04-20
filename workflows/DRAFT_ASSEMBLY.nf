include { QC                      } from "../subworkflows/QC.nf"
include { DOWNSAMPLE_AND_ASSEMBLE } from "../subworkflows/DOWNSAMPLE_AND_ASSEMBLE.nf"
include { ASSEMBLY_QC             } from "../subworkflows/ASSEMBLY_QC.nf"

workflow DRAFT_ASSEMBLY {
	// Check input parameters
	if (!params.input) {
        exit 1, "Missing input file."
    }

	if (!params.skip_kraken && !params.kraken_db) {
    	exit 1, "Missing Kraken database path."
	}

	if (!params.skip_checkm2 && !params.checkm2_db) {
        exit 1, "Missing CheckM2 database path."
    }

    // Channel
	Channel
        .fromPath(params.input, checkIfExists: true)
        .splitCsv(header:true, sep:",")
        .map { tuple(it.id, file(it.R1, checkIfExists: true), file(it.R2, checkIfExists: true), it.genome_size) }
        .set { input_ch }

	input_ch.map { id, R1, R2, gs -> tuple(id, gs) }
			.set { genome_size_ch }

	input_ch.map { id, R1, R2, gs -> tuple(id, R1, R2) }
			.set { reads_ch }

	// QC
	QC(reads_ch)

	QC.out.trimmed_ch.join(genome_size_ch).set { trimmed_with_gs }

	// Downsample and assembly
	DOWNSAMPLE_AND_ASSEMBLE(trimmed_with_gs)

	all_versions = QC.out.versions
        .mix(DOWNSAMPLE_AND_ASSEMBLE.out.versions)
        .collect()

	// Set multiqc channel
	QC.out.fastqc_pre_ch
		.mix(QC.out.fastqc_post_ch)
		.mix(params.skip_kraken ? Channel.empty() : QC.out.kraken_report_ch)
		.collect()
		.set { multiqc_input_ch }

	// Assembly QC
	ASSEMBLY_QC(DOWNSAMPLE_AND_ASSEMBLE.out.subsampled_reads,
				DOWNSAMPLE_AND_ASSEMBLE.out.assembly_ch,
				DOWNSAMPLE_AND_ASSEMBLE.out.quast_ch,
				all_versions,
				multiqc_input_ch)

	emit:
	ellipsis_ch = DOWNSAMPLE_AND_ASSEMBLE.out.assembly_ch
}
