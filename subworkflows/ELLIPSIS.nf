include { MOB_RECON                   } from "../modules/MOBSUITE.nf"
include { BAKTA                       } from "../modules/BAKTA.nf"
include { RESFINDER                   } from "../modules/RESFINDER.nf"
include { VIRULENCEFINDER             } from "../modules/VIRFINDER.nf"
include { PLASMIDFINDER               } from "../modules/PLASMIDFINDER.nf"
include { AMRFINDERPLUS               } from "../modules/AMRFINDERPLUS.nf"
include { REPORT_ELLIPSIS             } from "../modules/REPORT.nf"
include { MAKE_MQC_TOOL_VERSIONS      } from "../modules/MERGE.nf"
include { MULTIQC as MULTIQC_ELLIPSIS } from "../modules/MULTIQC.nf"

workflow ELLIPSIS {
	take: 
	assembly
	databases

	main:

	// Set database channels
	databases.filter{ it[0] == "bakta" }
		.map { it[1] }
        .first()
        .set { bakta_db }

	databases.filter{ it[0] == "resfinder" }
	    .map { it[1] }
	    .first()
	    .set { resfinder_db }

	databases.filter{ it[0] == "virulencefinder" }
        .map { it[1] }
        .first()
        .set { virfinder_db }

	databases.filter{ it[0] == "plasmidfinder" }
        .map { it[1] }
        .first()
        .set { plasmidfinder_db }

	databases.filter{ it[0] == "mobsuite" }
        .map { it[1] }
        .first()
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

	AMRFINDERPLUS(assembly)

	BAKTA.out.bakta_version
		.mix(RESFINDER.out.resfinder_version)
		.mix(VIRULENCEFINDER.out.virulencefinder_version)
		.mix(PLASMIDFINDER.out.plasmidfinder_version)
		.mix(AMRFINDERPLUS.out.amrfinderplus_version)
		.mix(MOB_RECON.out.mobsuite_version)
		.collect()
		.map { files ->
            files.groupBy { it.name }.collect { name, group -> group[0] }
        }
		.set { versions_ch }

	MAKE_MQC_TOOL_VERSIONS(versions_ch)

	REPORT_ELLIPSIS(RESFINDER.out.resfinder_out_ch.collect(),
			        VIRULENCEFINDER.out.virfinder_out_ch.collect(),
			        PLASMIDFINDER.out.plasmidfinder_out_ch.collect(),
			        AMRFINDERPLUS.out.amrfinderplus_out_ch.collect(),
			        MOB_RECON.out.mobsuite_out_ch.collect())

	BAKTA.out.bakta_txt_ch
		.mix(REPORT_ELLIPSIS.out.ellipsis_report_ch)
		.mix(MAKE_MQC_TOOL_VERSIONS.out.mqc_versions_tsv)
		.collect()
		.set { multiqc_input_ch }

	MULTIQC_ELLIPSIS(multiqc_input_ch)

}
