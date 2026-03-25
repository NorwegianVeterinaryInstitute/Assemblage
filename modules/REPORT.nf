process REPORT_DRAFT {
        conda (params.enable_conda ? './assets/r_env.yml' : null)
        container 'evezeyl/r_assemblage:latest'

        label 'process_short'

        input:
        file(quast_report)
	file(kraken_report)
	file(coverage_report)

        output:
        file("*")

        script:
        """
        cp $baseDir/bin/report_draft_assembly.Rmd .
        Rscript $baseDir/bin/gen_report.R "draft" $params.genome_size
        """
}

process REPORT_HYBRID {
        conda (params.enable_conda ? './assets/r_env.yml' : null)
        container 'evezeyl/r_assemblage:latest'

        label 'process_short'

        input:
        file(quast_report)
        file(completeness_report)
        file(coverage_report)
	file(np_coverage_report)
	file(kraken_report)

        output:
        file("*")

        script:
        """
        cp $baseDir/bin/report_hybrid_assembly.Rmd .
        Rscript $baseDir/bin/gen_report.R "hybrid" 10
        """
}

process REPORT_ELLIPSIS {
        conda (params.enable_conda ? './assets/r_env.yml' : null)
        container 'evezeyl/r_assemblage:latest'

        label 'process_short'

        input:
        path(resfinder_data)
        path(virfinder_data)
        path(plasmidfinder_data)
	path(mobsuite_data)

        output:
        path "ellipsis_report.tsv"

        script:
        """
        Rscript $baseDir/bin/ellipsis_report.R
        """
}
