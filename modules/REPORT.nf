process REPORT_DRAFT {
        conda (params.enable_conda ? './assets/r_env.yml' : null)
        container 'evezeyl/r_assemblage:latest'

        label 'process_short'

        input:
        file(quast_report)
	file(coverage_report)
        file(versions)

        output:
        file("*")

        script:
        """
        cp $baseDir/bin/report_draft_assembly.Rmd .
        Rscript $baseDir/bin/gen_report.R "draft" $params.genome_size $versions
        """
}

process REPORT_HYBRID {
        conda (params.enable_conda ? './assets/r_env.yml' : null)
        container 'evezeyl/r_assemblage:latest'

        label 'process_short'

        input:
        file(quast_report)
        file(coverage_report)
	file(np_coverage_report)
        file(versions)

        output:
        file("*")

        script:
        """
        cp $baseDir/bin/report_hybrid_assembly.Rmd .
        Rscript $baseDir/bin/gen_report.R "hybrid" 10 $versions
        """
}

process REPORT_KRAKEN {
        conda (params.enable_conda ? './assets/r_env.yml' : null)
        container 'evezeyl/r_assemblage:latest'

        label 'process_short'

        input:
        file(kraken_report)
        val(read_type)

        output:
        file("*")

        script:
        """
        cp $baseDir/bin/report_kraken_data.Rmd .
        Rscript $baseDir/bin/gen_kraken_report.R $read_type
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
        path(amrfinderplus_data)
	path(mobsuite_data)

        output:
        path "ellipsis_report.tsv"

        script:
        """
        Rscript $baseDir/bin/ellipsis_report.R
        """
}
