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
