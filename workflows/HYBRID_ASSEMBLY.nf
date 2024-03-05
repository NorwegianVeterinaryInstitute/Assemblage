include { FILTLONG         }	from "../modules/FILTLONG.nf"
include { UNICYCLER        }	from "../modules/UNICYCLER.nf"
include { QUAST            }	from "../modules/QUAST.nf"
include { BWA              }	from "../modules/BWA.nf"
include { SAMTOOLS         }	from "../modules/SAMTOOLS.nf"
include { BEDTOOLS         }	from "../modules/BEDTOOLS.nf"
include { MEDAKA           }    from "../modules/MEDAKA.nf"
include { POLYPOLISH       }	from "../modules/POLYPOLISH.nf"

workflow HYBRID_ASSEMBLY {
        // Channel

	def criteria = multiMapCriteria {
            id, R1, R2, NP ->
                shortreads: R1 != 'NA' ? tuple(tuple(id, [R1, R2])) : null
                longreads: NP != 'NA' ? tuple(id, NP) : null
	}

	Channel
	    .fromPath(params.input, checkIfExists: true)
	    .splitCsv(header:true, sep:",")
	    .map { row -> [row.id, row.R1, row.R2, row.NP] }
	    .multiMap (criteria)
	    .set { input_ch }

	input_ch
            .shortreads
            .filter{ it != null }
            .set { shortreads_ch }
    
        input_ch
            .longreads
            .filter{ it != null }
            .set { longreads_ch }

	shortreads_ch.join(longreads_ch, by: 0)
                     .set { assembly_ch }

	// Assembly
	UNICYCLER(assembly_ch)

/*
	// Coverage calculation
	illumina_ch.join(UNICYCLER_HYBRID.out.assembly_ch, by: 0)
		.set { mapping_ch }

	BWA(mapping_ch)
	SAMTOOLS(BWA.out.samtools_ch)
	BEDTOOLS(SAMTOOLS.out.bam_ch)

	// QC
	QUAST(UNICYCLER_HYBRID.out.quast_ch.collect())

	// Polishing
	nanopore_ch.join(UNICYCLER_HYBRID.assembly_ch, by: 0)
		.set { medaka_ch }

	MEDAKA(medaka_ch)

	MEDAKA.medaka_output_ch
		.join(BWA.out.bwa_polypolish_ch, by: 0)
		.set { polypolish_ch }

	POLYPOLISH(polypolish_ch)
*/
}
