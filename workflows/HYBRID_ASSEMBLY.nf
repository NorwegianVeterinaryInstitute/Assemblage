include { FILTLONG         }	from "../modules/FILTLONG.nf"
include { UNICYCLER_HYBRID }	from "../modules/UNICYCLER.nf"
include { QUAST            }	from "../modules/QUAST.nf"
include { BWA              }	from "../modules/BWA.nf"
include { SAMTOOLS         }	from "../modules/SAMTOOLS.nf"
include { BEDTOOLS         }	from "../modules/BEDTOOLS.nf"
include { POLYPOLISH       }	from "../modules/POLYPOLISH.nf"

workflow HYBRID_ASSEMBLY {
        // Channel
	nanopore_ch = Channel
		.fromPath(params.input, checkIfExists: true)
		.splitCsv(header:true, sep:",")
		.map { [it.sample, file(it.NP, checkIfExists: true)] }

        illumina_ch = Channel
                .fromPath(params.input, checkIfExists: true)
                .splitCsv(header:true, sep:",")
                .map { [it.sample, file(it.R1, checkIfExists: true), file(it.R2, checkIfExists: true)] }

	// Long read filtering
	FILTLONG(nanopore_ch)

	illumina_ch.join(FILTLONG.out.filtlong_ch, by: 0)
		.set { assembly_ch  }

	// Assembly
	UNICYCLER_HYBRID(assembly_ch)

	// Coverage calculation
	illumina_ch.join(UNICYCLER_HYBRID.out.assembly_ch, by: 0)
		.set { mapping_ch }

	BWA(mapping_ch)
	SAMTOOLS(BWA.out.samtools_ch)
	BEDTOOLS(SAMTOOLS.out.bam_ch)

	// QC
	QUAST(UNICYCLER_HYBRID.out.quast_ch.collect())

	// Polishing
	UNICYCLER_HYBRID.out.assembly_ch
		.join(BWA.out.bwa_polypolish_ch, by: 0)
		.set { polypolish_ch }

	POLYPOLISH(polypolish_ch)
}
