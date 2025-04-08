include { AUTOCYCLER_CLUSTER } from "../modules/AUTOCYCLER.nf"

workflow CLUSTER_AND_RESOLVE {

    take:
    graphs

    main:
    AUTOCYCLER_CLUSTER(graphs)

}