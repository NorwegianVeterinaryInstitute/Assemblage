include { RASUSA    } from "../modules/RASUSA.nf"
include { UNICYCLER } from "../modules/UNICYCLER.nf"

workflow DOWNSAMPLE_AND_ASSEMBLE {
    take:
    trim_reads

    main:
    // Downsample reads
    RASUSA(trim_reads)

	// Assembly
	UNICYCLER(RASUSA.out.subsampled_reads)

    emit:
    assembly_ch = UNICYCLER.out.assembly_ch
    quast_ch = UNICYCLER.out.quast_ch
    subsampled_reads = RASUSA.out.subsampled_reads
}