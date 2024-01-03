include { FILTLONG   }	from "../modules/FILTLONG.nf"
include { FLYE       }	from "../modules/FLYE.nf"
include { QUAST      }	from "../modules/QUAST.nf"
include { MEDAKA     }  from "../modules/MEDAKA.nf"
include { POLYPOLISH }	from "../modules/POLYPOLISH.nf"
include { POLCA      }  from "../modules/POLCA.nf"

workflow LONG_READ_ASSEMBLY {
        // Channel
	nanopore_ch = Channel
		.fromPath(params.input, checkIfExists: true)
		.splitCsv(header:true, sep:",")
		.map { [it.sample, file(it.NP, checkIfExists: true)] }

	// Long read filtering
	FILTLONG(nanopore_ch)

	// Assembly
	FLYE(FILTLONG.out.filtered_reads_ch)

	// QC
	QUAST(FLYE.out.quast_ch.collect())

	// Polishing
	nanopore_ch.join(FLYE.assembly_ch, by: 0)
		.set { medaka_ch }

	MEDAKA(medaka_ch)
	MEDAKA.medaka_output_ch
		.join(BWA.out.bwa_polypolish_ch, by: 0)
		.set { polypolish_ch }

	POLYPOLISH(polypolish_ch)
	POLCA()
}
