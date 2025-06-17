include { NPQC                } from "../subworkflows/NPQC.nf"
include { MULTIASSEMBLY       } from "../subworkflows/MULTIASSEMBLY.nf"
include { CLUSTER_AND_RESOLVE } from "../subworkflows/CLUSTER_AND_RESOLVE.nf"

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

	NPQC(input_ch)
	MULTIASSEMBLY(NPQC.out.reads)
    CLUSTER_AND_RESOLVE(MULTIASSEMBLY.out.graphs,
                        MULTIASSEMBLY.out.subset_yaml,
                        MULTIASSEMBLY.out.compress_yaml)
	
	emit:
	ellipsis_ch=CLUSTER_AND_RESOLVE.out.assemblies_ch
}
