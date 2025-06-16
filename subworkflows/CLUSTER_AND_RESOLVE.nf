include { AUTOCYCLER_CLUSTER } from "../modules/AUTOCYCLER.nf"
include { AUTOCYCLER_TRIM    } from "../modules/AUTOCYCLER.nf"
include { AUTOCYCLER_RESOLVE } from "../modules/AUTOCYCLER.nf"

workflow CLUSTER_AND_RESOLVE {

    take:
    graphs

    main:
    AUTOCYCLER_CLUSTER(graphs)

    AUTOCYCLER_CLUSTER.out.cluster_ch.view()

    AUTOCYCLER_CLUSTER.out.cluster_ch
        .transpose()
        .set { trim_input_ch }

    AUTOCYCLER_TRIM(trim_input_ch)
    AUTOCYCLER_RESOLVE(AUTOCYCLER_TRIM.out.trim_ch)
}