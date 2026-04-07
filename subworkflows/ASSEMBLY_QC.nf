include { QUAST                  } from "../modules/QUAST.nf"
include { BWA                    } from "../modules/BWA.nf"
include { SAMTOOLS               } from "../modules/SAMTOOLS.nf"
include { MERGE_COV_REPORTS      } from "../modules/MERGE.nf"
include { CHECKM2                } from "../modules/CHECKM.nf"
include { MULTIQC                } from "../modules/MULTIQC.nf"
include { MAKE_MQC_TOOL_VERSIONS } from "../modules/MERGE.nf"

workflow ASSEMBLY_QC {
    take:
    il_downsampled_reads
    assembly_ch
    quast_ch
    versions_ch
    multiqc_ch

    main:
    // Generate channel
	il_downsampled_reads.join(assembly_ch, by: 0)
        .set { mapping_ch }

    // Coverage calculation
	BWA(mapping_ch)

	SAMTOOLS(BWA.out.samtools_bwa_ch)

	// QC
	QUAST(quast_ch.collect())
	CHECKM2(quast_ch.collect())

    all_versions_for_mqc = versions_ch
        .mix(BWA.out.bwa_version)
        .mix(SAMTOOLS.out.samtools_version)
        .mix(QUAST.out.quast_version)
        .mix(CHECKM2.out.checkm2_version)
        .collect()
        .map { files ->
            files.groupBy { it.name }.collect { name, group -> group[0] }
        }

    // Convert .version files into MultiQC custom-content inputs
    MAKE_MQC_TOOL_VERSIONS(all_versions_for_mqc)

    // Assemble full MultiQC input: existing QC artefacts + custom versions files
    multiqc_ch
        .mix(QUAST.out.quast_multiqc_ch)
        .mix(SAMTOOLS.out.samtools_cov_ch)
        .mix(SAMTOOLS.out.samtools_stats_ch)
        .mix(CHECKM2.out.checkm2_ch)
        .mix(MAKE_MQC_TOOL_VERSIONS.out.mqc_versions_tsv)
        .collect()
        .set { multiqc_input }

    MULTIQC(multiqc_input)
}
