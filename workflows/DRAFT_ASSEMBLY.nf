include { FASTQC; FASTQC as FASTQC_POST } from "../modules/FASTQC.nf"
include { MULTIQC_PRE; MULTIQC_POST     } from "../modules/MULTIQC.nf"
include { KRAKEN                        } from "../modules/KRAKEN.nf"
include { TRIM                          } from "../modules/TRIM.nf"
include { UNICYCLER                     } from "../modules/UNICYCLER.nf"
include { QUAST                         } from "../modules/QUAST.nf"
include { BWA                           } from "../modules/BWA.nf"
include { SAMTOOLS                      } from "../modules/SAMTOOLS.nf"
include { BEDTOOLS                      } from "../modules/BEDTOOLS.nf"

workflow DRAFT_ASSEMBLY {
        // Channel

	Channel
            .fromPath(params.input, checkIfExists: true)
            .splitCsv(header:true, sep:",")
            .map { [it.id, it.R1, it.R2] }
            .set { input_ch }

	// QC
        FASTQC(input_ch)
        MULTIQC_PRE(FASTQC.out.fastqc_reports.collect())
        KRAKEN(input_ch)
        TRIM(input_ch)
        FASTQC_POST(TRIM.out.trim_reads)
        MULTIQC_POST(FASTQC_POST.out.fastqc_reports.collect())

	// Assembly
	UNICYCLER(TRIM.out.trim_reads)

	// Generate channel
	input_ch.join(UNICYCLER.out.assembly_ch, by: 0)
                .set { mapping_ch }

	// Coverage calculation
	BWA(mapping_ch)
	SAMTOOLS(BWA.out.samtools_ch)
	BEDTOOLS(SAMTOOLS.out.bam_ch)

	// QC
	QUAST(UNICYCLER.out.quast_ch.collect())

}
