log.info "=================================================="
log.info "                    ASSEMBLAGE                    "
log.info "=================================================="
log.info "Track: $params.track                              "
log.info "=================================================="

nextflow.enable.dsl=2

// Workflows
include { ASSEMBLY } from "${params.workflow_dir}/ASSEMBLY.nf"
include { QC } from "${params.workflow_dir}/QC.nf"

workflow {
	if (params.track == "qc") {
		QC()
	}

	if (params.track == "assembly") {
		ASSEMBLY()
	}
}
