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
	AUTOCYCLER_SUBSET(FILTLONG.out.filtlong_ch)

	// Set subset channels

	// Run assemblers
	CANU()
	FLYE()
	RAVEN()
	MINIMAP2_OVERLAP()
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
