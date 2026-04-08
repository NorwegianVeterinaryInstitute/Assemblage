log.info "=================================================="
log.info "                    ASSEMBLAGE                    "
log.info "=================================================="
log.info "Track: $params.track                              "
log.info "=================================================="

nextflow.enable.dsl=2

// Workflows
include { HYBRID_ASSEMBLY    } from "./workflows/HYBRID_ASSEMBLY.nf"
include { DRAFT_ASSEMBLY     } from "./workflows/DRAFT_ASSEMBLY.nf"
include { LONG_READ_ASSEMBLY } from "./workflows/LONG_READ_ASSEMBLY.nf"

// Subworkflows
include { ELLIPSIS    } from "./subworkflows/ELLIPSIS.nf"
include { VALIDATE_DB } from "./subworkflows/VALIDATE.nf"

workflow {

	def validTracks = ["hybrid", "draft", "long_read"]
	def track = params.track?.toString()?.trim()

	if (!track || !validTracks.contains(track)) {
    	exit 1, "Invalid --track value '${params.track}'. Valid options are: ${validTracks.join(', ')}"
	}

	// Check input parameters
	if (!params.input) {
        exit 1, "Missing input file."
    }

	if (!params.out_dir) {
        exit 1, "Missing output directory."
    }

	if (params.track == "hybrid") {
		HYBRID_ASSEMBLY()
		
	    if (params.ellipsis) {
				if (!params.databases) {
        			exit 1, "Missing databases file."
    			}

			VALIDATE_DB(params.databases)
			ELLIPSIS(HYBRID_ASSEMBLY.out.ellipsis_ch, 
				     VALIDATE_DB.out.valid_db_ch)
	    }
	}
	if (params.track == "draft") {
		DRAFT_ASSEMBLY()

	    if (params.ellipsis) {
				if (!params.databases) {
        			exit 1, "Missing databases file."
    			}

			VALIDATE_DB(params.databases)
            ELLIPSIS(DRAFT_ASSEMBLY.out.ellipsis_ch,
			         VALIDATE_DB.out.valid_db_ch)
        }
	}
	if (params.track == "long_read") {
		LONG_READ_ASSEMBLY()

		if (params.ellipsis) {
				if (!params.databases) {
					exit 1, "Missing databases file."
				}

			VALIDATE_DB(params.databases)
        	ELLIPSIS(LONG_READ_ASSEMBLY.out.ellipsis_ch,
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
