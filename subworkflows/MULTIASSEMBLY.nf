include { AUTOCYCLER_SUBSET } from "../modules/AUTOCYCLER.nf"
include { CANU              } from "../modules/CANU.nf"
include { FLYE              } from "../modules/FLYE.nf"
include { RAVEN             } from "../modules/RAVEN.nf"
include { MINIMAP2_OVERLAP  } from "../modules/MINIMAP.nf"
include { MINIASM           } from "../modules/MINIASM.nf"
include { MINIPOLISH        } from "../modules/MINIPOLISH.nf"
include { ANY2FASTA         } from "../modules/ANY2FASTA.nf"

workflow MULTIASSEMBLY {
	take: 
	reads

	main:
	// Subset reads
	AUTOCYCLER_SUBSET(reads)

	// Set assembly channels
	AUTOCYCLER_SUBSET.out.sub_ch.transpose()
		.collate( 4 )
		.set { subset_ch }

	sub_ch1 = subset_ch.map { it[0] }
	sub_ch2 = subset_ch.map { it[1] }
	sub_ch3 = subset_ch.map { it[2] }
	sub_ch4 = subset_ch.map { it[3] }

	// Run assemblers
	CANU(sub_ch1)
	FLYE(sub_ch2)
	RAVEN(sub_ch3)
	MINIMAP2_OVERLAP(sub_ch4)
	MINIASM(MINIMAP2_OVERLAP.out.minimap_overlap_ch)
	MINIPOLISH(MINIASM.out.miniasm_gfa_ch)
	ANY2FASTA(MINIPOLISH.out.miniasm_polished_ch)

	// Collect into channel
	canu_ch = CANU.out.canu_assembly_ch.collect()
	flye_ch = FLYE.out.flye_assembly_ch.collect()
	raven_ch = RAVEN.out.raven_assembly_ch.collect()
	miniasm_ch = ANY2FASTA.out.miniasm_assembly_ch.collect()

	// Set final output channel
	all_assemblies = canu_ch
            .join(flye_ch, by: 0)
            .join(raven_ch, by: 0)
            .join(miniasm_ch, by: 0)

	emit:
	all_assemblies
}
