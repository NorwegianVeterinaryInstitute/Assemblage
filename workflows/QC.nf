include { FASTQC; FASTQC as FASTQC_POST } from "../modules/FASTQC.nf"
include { MULTIQC_PRE; MULTIQC_POST     } from "../modules/MULTIQC.nf"
include { KRAKEN                        } from "../modules/KRAKEN.nf"
include { TRIM                          } from "../modules/TRIM.nf"

workflow QC {
        // Channel
	reads_ch = Channel
		.fromPath(params.input, checkIfExists: true)
		.splitCsv(header:true, sep:",")
		.map { [it.sample, file(it.R1, checkIfExists: true), file(it.R2, checkIfExists: true)] }

        // QC
        FASTQC(reads_ch)
        MULTIQC_PRE(FASTQC.out.fastqc_reports.collect())
	KRAKEN(reads_ch)
	TRIM(reads_ch)
	FASTQC_POST(TRIM.out.trim_reads)
	MULTIQC_POST(FASTQC_POST.out.fastqc_reports.collect())
}
