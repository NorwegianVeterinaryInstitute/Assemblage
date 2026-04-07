include { NPQC                } from "../subworkflows/NPQC.nf"
include { MULTIASSEMBLY       } from "../subworkflows/MULTIASSEMBLY.nf"
include { CLUSTER_AND_RESOLVE } from "../subworkflows/CLUSTER_AND_RESOLVE.nf"
include { POLISHING           } from "../subworkflows/POLISHING.nf"
include { HYBRID_ASSEMBLY_QC  } from "../subworkflows/HYBRID_ASSEMBLY_QC.nf"

workflow LONG_READ_ASSEMBLY {

	// Check input parameters
	if (!params.input) {
        exit 1, "Missing input file."
    }

	Channel
        .fromPath(params.input, checkIfExists: true)
        .splitCsv(header:true, sep:",")
        .map { tuple(it.id, file(it.np, checkIfExists: true)) }
        .set { input_ch }

    Channel
        .fromPath(params.input, checkIfExists: true)
        .splitCsv(header:true, sep:",")
        .map { tuple(it.id, file(it.R1, checkIfExists: true), file(it.R2, checkIfExists: true)) }
        .set { illumina_ch }

	NPQC(input_ch)
	MULTIASSEMBLY(NPQC.out.reads)
    CLUSTER_AND_RESOLVE(MULTIASSEMBLY.out.graphs,
                        MULTIASSEMBLY.out.subset_yaml,
                        MULTIASSEMBLY.out.compress_yaml)

    illumina_ch
        .join(CLUSTER_AND_RESOLVE.out.assemblies_ch, by: 0)
        .set { POLISHING_input_ch }

    POLISHING(POLISHING_input_ch)

    NPQC.out.versions
        .mix(MULTIASSEMBLY.out.versions)
        .mix(CLUSTER_AND_RESOLVE.out.versions)
        .mix(POLISHING.out.versions)
        .collect()
        .set { all_versions }

    POLISHING.out.quast_compare_out
        .mix(CLUSTER_AND_RESOLVE.out.autocycler_table)
        .mix(params.skip_kraken ? Channel.empty() : NPQC.out.kraken_long_report_ch)
        .collect()
        .set { multiqc_input_ch }

    HYBRID_ASSEMBLY_QC(illumina_ch,
                       NPQC.out.reads,
                       POLISHING.out.polish_out,
                       CLUSTER_AND_RESOLVE.out.quast_ch,
                       all_versions,
                       multiqc_input_ch)
	
	emit:
	ellipsis_ch=POLISHING.out.polish_out
}
