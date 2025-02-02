include { MOB_RECON       } from "../modules/MOBSUITE.nf"
include { BAKTA           } from "../modules/BAKTA.nf"
include { RESFINDER       } from "../modules/RESFINDER.nf"
include { VIRULENCEFINDER } from "../modules/VIRFINDER.nf"
include { PLASMIDFINDER   } from "../modules/PLASMIDFINDER.nf"

workflow ELLIPSIS {
	take: 
	assemblies

	main:
	// Set channels
	Channel
	    .fromPath(params.mobsuite_db, checkIfExists: true)
	    .set { mobsuite_db_ch }

	assemblies.combine(mobsuite_db_ch)
	    .set { input_ch }

	// Run modules
	BAKTA(assemblies)
	RESFINDER(assemblies)
	VIRULENCEFINDER(assemblies)
	PLASMIDFINDER(assemblies)

	MOB_RECON(input_ch)
}
