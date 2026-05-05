include { QUAST                  } from "../modules/QUAST.nf"
include { BWA                    } from "../modules/BWA.nf"
include { SAMTOOLS               } from "../modules/SAMTOOLS.nf"
include { BEDTOOLS               } from "../modules/BEDTOOLS.nf"
include { MINIMAP2               } from "../modules/MINIMAP.nf"
include { CHECKM2                } from "../modules/CHECKM.nf"
include { MULTIQC                } from "../modules/MULTIQC.nf"
include { MAKE_MQC_TOOL_VERSIONS } from "../modules/MERGE.nf"

workflow HYBRID_ASSEMBLY_QC {
    take:
    il_downsampled_reads
    np_downsampled_reads
    assembly_ch
    quast_ch
    versions_ch
    multiqc_ch

    main:
    // Generate channel
	il_downsampled_reads.join(assembly_ch, by: 0)
        .set { il_mapping_ch }

    np_downsampled_reads.join(assembly_ch, by: 0)
        .set { np_mapping_ch }

    // Coverage calculation
	BWA(il_mapping_ch)
    MINIMAP2(np_mapping_ch)

    bwa_samtools_ch = BWA.out.samtools_bwa_ch
        .map { id, bam -> tuple(id, "short", bam) }

    np_samtools_ch = MINIMAP2.out.samtools_np_ch
        .map { id, bam -> tuple(id, "long", bam) }

    bwa_samtools_ch
        .concat(np_samtools_ch)
        .set { samtools_ch }
    
	SAMTOOLS(samtools_ch)

	// QC
    def batchSize = params.batch_size.toString().toInteger()
    def batchId = 0

    quast_ch
        .collate(batchSize)
        .map { batch -> tuple(++batchId, batch) }
        .set { genome_batches }

	QUAST(genome_batches)
    
    if (!params.skip_checkm2) {
        checkm_db_ch = Channel.value( file(params.checkm2_db, checkIfExists: true) )

        genome_batches
            .combine(checkm_db_ch)
            .set { checkm_input_ch }

        CHECKM2(checkm_input_ch)

        CHECKM2.out.checkm2_ch
            .map { batch_id, checkm2_dir -> checkm2_dir }
            .set { clean_checkm2_ch }
    }

    all_versions_for_mqc = versions_ch
        .mix(BWA.out.bwa_version)
        .mix(MINIMAP2.out.minimap2_version)
        .mix(SAMTOOLS.out.samtools_version)
        .mix(QUAST.out.quast_version)
        .mix(params.skip_checkm2 ? Channel.empty() : CHECKM2.out.checkm2_version)
        .collect()
        .map { files ->
            files.groupBy { it.name }.collect { name, group -> group[0] }
        }

    MAKE_MQC_TOOL_VERSIONS(all_versions_for_mqc)

    QUAST.out.quast_multiqc_ch
        .map { batch_id, quast_dir -> quast_dir }
        .set { clean_quast_multiqc_ch }

    multiqc_ch
        .mix(clean_quast_multiqc_ch)
        .mix(SAMTOOLS.out.samtools_cov_ch)
        .mix(SAMTOOLS.out.samtools_stats_ch)
        .mix(params.skip_checkm2 ? Channel.empty() : clean_checkm2_ch)
        .mix(MAKE_MQC_TOOL_VERSIONS.out.mqc_versions_tsv)
        .collect()
        .set { multiqc_input }

    MULTIQC(multiqc_input)
}