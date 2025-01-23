include { FILTLONG         }	from "../modules/FILTLONG.nf"
include { UNICYCLER_HYBRID }	from "../modules/UNICYCLER.nf"
include { QUAST            }	from "../modules/QUAST.nf"
include { BWA              }	from "../modules/BWA.nf"
include { SAMTOOLS         }	from "../modules/SAMTOOLS.nf"
include { BEDTOOLS         }	from "../modules/BEDTOOLS.nf"
include { POLYPOLISH       }	from "../modules/POLYPOLISH.nf"

workflow HYBRID_ASSEMBLY {
        // Channel

	Channel
            .fromPath(params.input, checkIfExists: true)
            .splitCsv(header:true, sep:",")
            .map { tuple(it.id, file(it.R1, checkIfExists: true), file(it.R2, checkIfExists: true), file(it.np, checkIfExists: true)) }
            .set { input_ch }

	input_ch
                .map { id, R1, R2, np ->
                        tuple( id, R1, R2 )
                }
                .set { illumina_ch }

        input_ch
                .map { id, R1, R2, np ->
                        tuple( id, np )
                }
                .set { nanopore_ch }

	// Read filtering
	FILTLONG(nanopore_ch)

	illumina_ch.join(FILTLONG.out.filtlong_ch, by: 0)
		.set { assembly_ch }

	// Assembly
	UNICYCLER_HYBRID(assembly_ch)

	// Coverage calculation
	illumina_ch.join(UNICYCLER_HYBRID.out.assemblies_ch, by: 0)
		.set { mapping_ch }

	BWA(mapping_ch)
	SAMTOOLS(BWA.out.samtools_ch)
	BEDTOOLS(SAMTOOLS.out.bam_ch)

	// QC
	QUAST(UNICYCLER_HYBRID.out.quast_ch.collect())

	// Polishing
	nanopore_ch.join(UNICYCLER_HYBRID.out.assemblies_ch, by: 0)
		.join(BWA.out.bwa_polypolish_ch, by: 0)
		.set { polypolish_ch }

	POLYPOLISH(polypolish_ch)
}
