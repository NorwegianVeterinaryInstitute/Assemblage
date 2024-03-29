include { UNICYCLER_HYBRID }	from "../modules/UNICYCLER.nf"
include { QUAST            }	from "../modules/QUAST.nf"
include { BWA              }	from "../modules/BWA.nf"
include { SAMTOOLS         }	from "../modules/SAMTOOLS.nf"
include { BEDTOOLS         }	from "../modules/BEDTOOLS.nf"

workflow HYBRID_ASSEMBLY {
        // Channel
	reads_ch = Channel
                .fromPath(params.input, checkIfExists: true)
                .splitCsv(header:true, sep:",")
                .map { [it.sample, file(it.R1, checkIfExists: true), file(it.R2, checkIfExists: true), file(it.NP, checkIfExists: true)] }

	nanopore_ch = Channel
		.fromPath(params.input, checkIfExists: true)
		.splitCsv(header:true, sep:",")
		.map( [it.sample, file(it.NP, checkIfExists: true)] )

        illumina_ch = Channel
                .fromPath(params.input, checkIfExists: true)
                .splitCsv(header:true, sep:",")
                .map( [it.sample, file(it.R1, checkIfExists: true), file(it.R2, checkIfExists: true)] )

	// Assembly
	UNICYCLER_HYBRID(reads_ch)

	// Coverage calculation
	illumina_ch.join(UNICYCLER_HYBRID.out.assembly_ch, by: 0)
		.set { mapping_ch }

	BWA(mapping_ch)
	SAMTOOLS(BWA.out.samtools_ch)
	BEDTOOLS(SAMTOOLS.out.bam_ch)

	// QC
	QUAST(UNICYCLER.out.quast_ch.collect())

	// Polishing
	nanopore_ch.join(UNICYCLER_HYBRID.out.assembly_ch, by: 0)
		.set { polishing_ch }
	
	MEDAKA(polishing_ch)
	
	illumina_ch.join(MEDAKA.out.medaka_ch, by: 0)
		.set { polypolish_ch  }

	POLYPOLISH(polypolish_ch)
}
