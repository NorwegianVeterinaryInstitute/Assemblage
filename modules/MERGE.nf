process MERGE_KRAKEN_REPORTS {
        conda (params.enable_conda ? './assets/r_env.yml' : null)
        container 'evezeyl/r_assemblage:latest'

        input:
        path(reports)

        output:
        path "*"
	path "kraken_reports.txt", emit: kraken_report

        script:
        """
        Rscript $baseDir/bin/merge_kraken_data.R
        """
}

process MERGE_COV_REPORTS {
        conda (params.enable_conda ? './assets/r_env.yml' : null)
        container 'evezeyl/r_assemblage:latest'

	label 'process_high_memory'

        input:
        path(reports)

        output:
        path "*"
        path "coverage_reports.txt", emit: coverage_report

        script:
        """
        Rscript $baseDir/bin/merge_cov_data.R
        """
}

process MERGE_NP_COV_REPORTS {
        conda (params.enable_conda ? './assets/r_env.yml' : null)
        container 'evezeyl/r_assemblage:latest'

        label 'process_high_memory'

        input:
        path(reports)

        output:
        path "*"
        path "coverage_reports.txt", emit: np_coverage_report

        script:
        """
        Rscript $baseDir/bin/merge_np_cov_data.R
        """
}

process MERGE_COMPLETENESS_REPORTS {
        conda (params.enable_conda ? './assets/r_env.yml' : null)
        container 'evezeyl/r_assemblage:latest'

        label 'process_high_memory'

        input:
        path(reports)

        output:
        path "*"
        path "completeness_reports.txt", emit: completeness_report

        script:
        """
        Rscript $baseDir/bin/merge_completeness_data.R
        """
}
