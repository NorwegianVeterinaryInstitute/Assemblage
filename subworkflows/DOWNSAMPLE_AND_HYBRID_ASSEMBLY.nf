include { RASUSA|RASUSA_LONG } from "../modules/RASUSA.nf"
include { UNICYCLER_HYBRID   } from "../modules/UNICYCLER.nf"
include { SPADES_HYBRID      } from "../modules/SPADES.nf"
include { FILTLONG           } from "../modules/FILTLONG.nf"
include { DNAAPLER_FASTA     } from "../modules/DNAAPLER.nf"

workflow DOWNSAMPLE_AND_HYBRID_ASSEMBLY {
    take:
    illumina_reads
    nanopore_reads

    main:
    if (!params.genome_size) {
        exit 1, "Missing genome size parameter."
    }

    // Downsample reads
    RASUSA(illumina_reads)
    RASUSA_LONG(nanopore_reads)

	// Assembly
    if (params.spades) {
        SPADES_HYBRID(RASUSA.out.subsampled_reads, 
                      RASUSA_LONG.out.subsampled_long_reads)
        DNAAPLER_FASTA(SPADES_HYBRID.out.assemblies_ch)
    } else {
        UNICYCLER_HYBRID(RASUSA.out.subsampled_reads, 
                         RASUSA_LONG.out.subsampled_long_reads)
        DNAAPLER_FASTA(UNICYCLER_HYBRID.out.assemblies_ch)
    }

    RASUSA.out.subsampled_reads
        .join(DNAAPLER_FASTA.out.assemblies_ch, by: 0)
        .set { polishing_ch }

    emit:
    polishing_ch
    quast_ch = DNAAPLER_FASTA.out.quast_ch
    subsampled_reads = RASUSA.out.subsampled_reads
}