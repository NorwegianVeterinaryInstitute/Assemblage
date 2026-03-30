include { QC                             } from "../subworkflows/QC.nf"
include { NPQC                           } from "../subworkflows/NPQC.nf"
include { DOWNSAMPLE_AND_HYBRID_ASSEMBLY } from "../subworkflows/DOWNSAMPLE_AND_HYBRID_ASSEMBLY.nf"
include { POLISHING                      } from "../subworkflows/POLISHING.nf"
include { ASSEMBLY_QC                    } from "../subworkflows/ASSEMBLY_QC.nf"
include { MERGE_REPORTS                  } from "../modules/MERGE.nf"
include { REPORT_HYBRID                  } from "../modules/REPORT.nf"

workflow HYBRID_ASSEMBLY {
    // Check input parameters
    if (!params.input) {
        exit 1, "Missing input file."
    }

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

    ASSEMBLY_QC(POLISHING.out.polish_out, 
                DOWNSAMPLE_AND_HYBRID_ASSEMBLY.out.subsampled_reads, 
                DOWNSAMPLE_AND_HYBRID_ASSEMBLY.out.quast_ch)

    // Merge reports
    MERGE_REPORTS(
        POLISHING.out.quast_compare_out,
        ASSEMBLY_QC.out.coverage_report
    )

    // Reporting
    REPORT_HYBRID(
        MERGE_REPORTS.out.quast_report_ch,
        MERGE_REPORTS.out.completeness_report_ch,
        MERGE_REPORTS.out.il_coverage_report_ch,
        MERGE_REPORTS.out.np_coverage_report_ch,
        MERGE_REPORTS.out.kraken_report_ch
    )

    emit:
    ellipsis_ch = POLISHING.out.polish_out
}
