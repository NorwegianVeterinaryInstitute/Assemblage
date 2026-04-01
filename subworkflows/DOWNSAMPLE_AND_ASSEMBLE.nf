include { RASUSA    } from "../modules/RASUSA.nf"
include { UNICYCLER } from "../modules/UNICYCLER.nf"

workflow DOWNSAMPLE_AND_ASSEMBLE {
    take:
    trim_reads

    main:
    // Downsample reads
    RASUSA(trim_reads)

	// Assembly
    if (params.spades) {
        SPADES(RASUSA.out.subsampled_reads)
    } else {
        UNICYCLER(RASUSA.out.subsampled_reads)
    }
	
    emit:
    assembly_ch = params.spades ? SPADES.out.assembly_ch : UNICYCLER.out.assembly_ch
    quast_ch = params.spades ? SPADES.out.quast_ch : UNICYCLER.out.quast_ch
    subsampled_reads = RASUSA.out.subsampled_reads
    versions = RASUSA.out.rasusa_version
        .mix(params.spades ? SPADES.out.spades_version : UNICYCLER.out.unicycler_version)
        .collect()
}