include { QUAST             } from "../modules/QUAST.nf"
include { BWA               } from "../modules/BWA.nf"
include { SAMTOOLS          } from "../modules/SAMTOOLS.nf"
include { BEDTOOLS          } from "../modules/BEDTOOLS.nf"
include { MINIMAP2          } from "../modules/MINIMAP.nf"
include { MERGE_COV_REPORTS } from "../modules/MERGE.nf"
include { CHECKM2           } from "../modules/CHECKM.nf"

workflow HYBRID_ASSEMBLY_QC {
    take:
    il_downsampled_reads
    np_downsampled_reads
    assembly_ch
    quast_ch

    main:
    // Generate channel
	il_downsampled_reads.join(assembly_ch, by: 0)
        .set { il_mapping_ch }

    np_downsampled_reads.join(assembly_ch, by: 0)
        .set { np_mapping_ch }

    // Coverage calculation
	BWA(il_mapping_ch)
    MINIMAP2(np_mapping_ch)

    BWA.out.samtools_bwa_ch
		.concat(MINIMAP2.out.samtools_np_ch)
		.set { samtools_ch }
    
	SAMTOOLS(samtools_ch)
	BEDTOOLS(SAMTOOLS.out.bam_ch)

	// QC
	QUAST(quast_ch.collect())
	// CHECKM2(assembly_ch.map { id, fasta -> fasta }.collect())

    emit:
    quast_report = QUAST.out.R_quast
    il_coverage_report = BEDTOOLS.out.il_cov_report_ch
    np_coverage_report = BEDTOOLS.out.np_cov_report_ch
    //completeness_report = CHECKM2.out.checkm2_ch
    versions = BWA.out.bwa_version
        .mix(MINIMAP2.out.minimap2_version)
        .mix(SAMTOOLS.out.samtools_version)
        .mix(BEDTOOLS.out.bedtools_version)
        .collect()
        .map { files ->
            files
                .groupBy { it.name }
                .collect { name, group -> group[0] }
        }
}