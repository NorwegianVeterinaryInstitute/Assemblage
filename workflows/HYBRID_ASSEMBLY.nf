include { QC                             } from "../subworkflows/QC.nf"
include { NPQC                           } from "../subworkflows/NPQC.nf"
include { DOWNSAMPLE_AND_HYBRID_ASSEMBLY } from "../subworkflows/DOWNSAMPLE_AND_HYBRID_ASSEMBLY.nf"
include { POLISHING                      } from "../subworkflows/POLISHING.nf"
include { HYBRID_ASSEMBLY_QC             } from "../subworkflows/HYBRID_ASSEMBLY_QC.nf"

workflow HYBRID_ASSEMBLY {
    // Check input parameters
    if (!params.input) {
        exit 1, "Missing input file."
    }

    // TODO - Implement multiQC as final reporting step

    // Channels
    Channel
        .fromPath(params.input, checkIfExists: true)
        .splitCsv(header:true, sep:",")
        .map { tuple(it.id, file(it.R1, checkIfExists: true), file(it.R2, checkIfExists: true), file(it.np, checkIfExists: true)) }
        .set { input_ch }

    input_ch
        .map { id, R1, R2, np ->
            tuple(id, R1, R2)
        }
        .set { illumina_ch }

    input_ch
        .map { id, R1, R2, np ->
            tuple(id, np)
        }
        .set { nanopore_ch }


    QC(illumina_ch)
    NPQC(nanopore_ch)

    DOWNSAMPLE_AND_HYBRID_ASSEMBLY(QC.out.trimmed_ch, 
                                   NPQC.out.reads)

    POLISHING(DOWNSAMPLE_AND_HYBRID_ASSEMBLY.out.polishing_ch)

    // Collect versions
    all_versions = QC.out.versions
        .mix(NPQC.out.versions)
        .mix(DOWNSAMPLE_AND_HYBRID_ASSEMBLY.out.versions)
        .mix(POLISHING.out.versions)
        .collect()

	// Set multiqc channel
	QC.out.fastqc_pre_ch
		.mix(QC.out.fastqc_post_ch)
        .mix(NPQC.out.reads)
		.mix(params.skip_kraken ? Channel.empty() : QC.out.kraken_report_ch)
        .mix(params.skip_kraken ? Channel.empty() : NPQC.out.kraken_long_report_ch)
        .mix(POLISHING.out.quast_compare_out)
		.collect()
		.set { multiqc_input_ch }

    HYBRID_ASSEMBLY_QC(DOWNSAMPLE_AND_HYBRID_ASSEMBLY.out.il_subsampled_reads,
                       DOWNSAMPLE_AND_HYBRID_ASSEMBLY.out.np_subsampled_reads,
                       POLISHING.out.polish_out,  
                       DOWNSAMPLE_AND_HYBRID_ASSEMBLY.out.quast_ch,
                       all_versions,
                       multiqc_input_ch)


    emit:
    ellipsis_ch = POLISHING.out.polish_out
}
