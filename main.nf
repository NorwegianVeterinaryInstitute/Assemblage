log.info "=================================================="
log.info "                    ASSEMBLAGE                    "
log.info "=================================================="
log.info "Track: $params.track                              "
log.info "=================================================="

nextflow.enable.dsl=2

// Workflows
include { HYBRID_ASSEMBLY } from "./workflows/HYBRID_ASSEMBLY.nf"
include { DRAFT_ASSEMBLY  } from "./workflows/DRAFT_ASSEMBLY.nf"

// Subworkflows
include { ELLIPSIS    } from "./subworkflows/ELLIPSIS.nf"
include { VALIDATE_DB } from "./subworkflows/VALIDATE.nf"

workflow {
	if (params.track == "hybrid") {
		HYBRID_ASSEMBLY()
		
	    if (params.ellipsis) {

		VALIDATE_DB(params.databases)
		ELLIPSIS(HYBRID_ASSEMBLY.out.ellipsis_ch, 
			 VALIDATE_DB.out.valid_db_ch)
	    }
	}
	if (params.track == "draft") {
		DRAFT_ASSEMBLY()

	    if (params.ellipsis) {

		VALIDATE_DB(params.databases)
                ELLIPSIS(DRAFT_ASSEMBLY.out.ellipsis_ch,
			 VALIDATE_DB.out.valid_db_ch)
            }
	}
}

workflow.onComplete {
	log.info "".center(60, "=")
	log.info "Assemblage $params.track Complete!".center(60)
	log.info "Output directory: $params.out_dir".center(60)
	log.info "Duration: $workflow.duration".center(60)
	log.info "Command line: $workflow.commandLine".center(60)
	log.info "Nextflow version: $workflow.nextflow.version".center(60)
	log.info "".center(60, "=")
}

workflow.onError {
	println "Pipeline execution stopped with the following message: ${workflow.errorMessage}"
}
