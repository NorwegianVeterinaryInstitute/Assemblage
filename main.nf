log.info "=================================================="
log.info "                    ASSEMBLAGE                    "
log.info "=================================================="

nextflow.enable.dsl=2

// Workflows
include { ASSEMBLY } from "${params.workflow_dir}/ASSEMBLY.nf"

workflow {
	ASSEMBLY()
}
