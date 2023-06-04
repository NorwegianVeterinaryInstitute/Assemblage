include { UNICYCLER }	from "../modules/UNICYCLER.nf"
include { QUAST     }	from "../modules/QUAST.nf"
include { BWA       }	from "../modules/BWA.nf"
include { SAMTOOLS  }	from "../modules/SAMTOOLS.nf"
include { BEDTOOLS  }	from "../modules/BEDTOOLS.nf"

workflow ASSEMBLY {
        // Channel
	reads_ch = Channel
                .fromPath(params.input, checkIfExists: true)
                .splitCsv(header:true, sep:",")
                .map { file -> tuple(sample, file(it.R1, checkIfExists: true), file(it.R2, checkIfExists: true)) }

	// Assembly
	UNICYCLER(reads_ch)

	// Generate channel
	reads_ch.join(UNICYCLER.out.assembly_ch, by: 0)
		.set { mapping_ch }

	// Coverage calculation
	BWA(mapping_ch)
	SAMTOOLS(BWA.out.samtools_ch)
	BEDTOOLS(SAMTOOLS.out.bam_ch)

	// QC
	QUAST(UNICYCLER.out.quast_ch.collect())
}
