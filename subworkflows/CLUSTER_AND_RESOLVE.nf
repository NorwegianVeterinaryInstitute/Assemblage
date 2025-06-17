include { AUTOCYCLER_CLUSTER } from "../modules/AUTOCYCLER.nf"
include { AUTOCYCLER_TRIM    } from "../modules/AUTOCYCLER.nf"
include { AUTOCYCLER_RESOLVE } from "../modules/AUTOCYCLER.nf"
include { AUTOCYCLER_COMBINE } from "../modules/AUTOCYCLER.nf"
include { AUTOCYCLER_DOTPLOT } from "../modules/AUTOCYCLER.nf"
include { AUTOCYCLER_TABLE   } from "../modules/AUTOCYCLER.nf"

workflow CLUSTER_AND_RESOLVE {

    take:
    graphs
    subset
    compress

    main:
    AUTOCYCLER_CLUSTER(graphs)

    AUTOCYCLER_CLUSTER.out.cluster_ch
        .flatMap { id, dirs ->
            dirs.collect { dir ->
                def cluster_name = dir.getBaseName()
                def base = file(dir).toAbsolutePath()
                def files = base.list().collect { f -> base.resolve(f) }
                tuple(id, cluster_name, files)
            }
        }
        .set {trim_input_ch}

    AUTOCYCLER_TRIM(trim_input_ch)
    AUTOCYCLER_DOTPLOT(AUTOCYCLER_TRIM.out.dotplot_ch)
    AUTOCYCLER_RESOLVE(AUTOCYCLER_TRIM.out.trim_ch)

    AUTOCYCLER_RESOLVE.out.resolve_ch
       .groupTuple()
       .set { combine_input_ch }

    AUTOCYCLER_COMBINE(combine_input_ch)

    subset
        .join(compress, by: 0)
        .join(AUTOCYCLER_CLUSTER.out.clustering_yaml_ch, by: 0)
        .join(AUTOCYCLER_TRIM.out.trimming_yaml_ch, by: 0)
        .join(AUTOCYCLER_COMBINE.out.combine_yaml_ch, by: 0)
        .map { id, yaml1, yaml2, yaml3, yaml4, yaml5 -> tuple(id, [yaml1, yaml2, yaml3, yaml4, yaml5]) }
        .set { table_ch }

    AUTOCYCLER_TABLE(table_ch)

    emit: 
    assemblies_ch=AUTOCYCLER_COMBINE.out.assemblies_ch.collect()
}