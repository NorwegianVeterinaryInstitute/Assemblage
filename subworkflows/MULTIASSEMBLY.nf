include { AUTOCYCLER_SUBSET   } from "../modules/AUTOCYCLER.nf"
include { CANU                } from "../modules/CANU.nf"
include { FLYE                } from "../modules/FLYE.nf"
include { RAVEN               } from "../modules/RAVEN.nf"
include { MINIMAP2_OVERLAP    } from "../modules/MINIMAP.nf"
include { MINIASM             } from "../modules/MINIASM.nf"
include { MINIPOLISH          } from "../modules/MINIPOLISH.nf"
include { ANY2FASTA           } from "../modules/ANY2FASTA.nf"
include { AUTOCYCLER_COMPRESS } from "../modules/AUTOCYCLER.nf"

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

	// Merge channels
	canu_ch = CANU.out.canu_assembly_ch
		.groupTuple()
		.map { meta, paths -> tuple(meta, paths.flatten()) }

	flye_ch = FLYE.out.flye_assembly_ch
		.groupTuple()
		.map { meta, paths -> tuple(meta, paths.flatten()) }

    raven_ch = RAVEN.out.raven_assembly_ch
		.groupTuple()
		.map { meta, paths -> tuple(meta, paths.flatten()) }

	miniasm_ch = ANY2FASTA.out.miniasm_assembly_ch
		.groupTuple()
		.map { meta, paths -> tuple(meta, paths.flatten()) }

	all_assemblies = canu_ch.join(flye_ch)
		.join(raven_ch)
		.join(miniasm_ch)
	
	// Run autocycler compress
	AUTOCYCLER_COMPRESS(all_assemblies)

	emit:
	graphs=AUTOCYCLER_COMPRESS.out.compress_ch
}