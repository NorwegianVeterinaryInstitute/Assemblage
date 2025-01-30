include { MOB_RECON } from "../modules/MOBSUITE.nf"
include { BAKTA     } from "../modules/BAKTA.nf"

workflow ELLIPSIS {
	take: 
	assemblies

	main:
	Channel
	    .fromPath(params.mobsuite_db, checkIfExists: true)
	    .set { mobsuite_db_ch }

	assemblies.combine(mobsuite_db_ch)
	    .set { input_ch }

	BAKTA(assemblies)
	MOB_RECON(input_ch)

	MOB_RECON.out.mob_replicon_ch.view()
}
