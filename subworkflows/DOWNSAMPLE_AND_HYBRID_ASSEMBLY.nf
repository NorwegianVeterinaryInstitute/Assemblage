include { RASUSA; RASUSA_LONG } from "../modules/RASUSA.nf"
include { UNICYCLER_HYBRID    } from "../modules/UNICYCLER.nf"
include { SPADES_HYBRID       } from "../modules/SPADES.nf"
include { FILTLONG            } from "../modules/FILTLONG.nf"
include { DNAAPLER_FASTA      } from "../modules/DNAAPLER.nf"

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

    RASUSA.out.subsampled_reads
        .join(RASUSA_LONG.out.subsampled_long_reads, by: 0)
        .map { id, r1, r2, np -> tuple(id, r1, r2, np) }
        .set { assembly_input_ch }

	// Assembly
    if (params.spades) {
        SPADES_HYBRID(assembly_input_ch)
        DNAAPLER_FASTA(SPADES_HYBRID.out.assemblies_ch)
    } else {
        UNICYCLER_HYBRID(assembly_input_ch)
        DNAAPLER_FASTA(UNICYCLER_HYBRID.out.assemblies_ch)
    }

    RASUSA.out.subsampled_reads
        .join(DNAAPLER_FASTA.out.dnaapler_reoriented_ch, by: 0)
        .set { polishing_ch }

    emit:
    polishing_ch
    quast_ch = DNAAPLER_FASTA.out.quast_ch
    subsampled_reads = RASUSA.out.subsampled_reads
}