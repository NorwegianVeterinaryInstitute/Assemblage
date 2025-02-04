include { MOB_RECON       } from "../modules/MOBSUITE.nf"
include { BAKTA           } from "../modules/BAKTA.nf"
include { RESFINDER       } from "../modules/RESFINDER.nf"
include { VIRULENCEFINDER } from "../modules/VIRFINDER.nf"
include { PLASMIDFINDER   } from "../modules/PLASMIDFINDER.nf"

workflow ELLIPSIS {
	take: 
	assembly
	databases

	main:

	// Set database channels
	databases.filter{ it[0] == "bakta" }
            .flatten()
            .last()
            .set { bakta_db }

	databases.filter{ it[0] == "resfinder" }
	    .flatten()
	    .last()
	    .set { resfinder_db }

	databases.filter{ it[0] == "virulencefinder" }
            .flatten()
            .last()
            .set { virfinder_db }

	databases.filter{ it[0] == "plasmidfinder" }
            .flatten()
            .last()
            .set { plasmidfinder_db }

	databases.filter{ it[0] == "mobsuite" }
            .flatten()
            .last()
            .set { mobsuite_db }

	assembly.combine(bakta_db)
	    .set { bakta_ch }
	
	assembly.combine(resfinder_db)
            .set { resfinder_ch }

	assembly.combine(virfinder_db)
            .set { virfinder_ch }

	assembly.combine(plasmidfinder_db)
            .set { plasmidfinder_ch }

	assembly.combine(mobsuite_db)
            .set { mobsuite_ch }


	// Run modules
	BAKTA(bakta_ch)
	RESFINDER(resfinder_ch)
	VIRULENCEFINDER(virfinder_ch)
	PLASMIDFINDER(plasmidfinder_ch)
	MOB_RECON(mobsuite_ch)
}
