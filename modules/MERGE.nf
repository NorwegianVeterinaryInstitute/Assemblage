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

process MERGE_REPORTS {
        conda (params.enable_conda ? './assets/r_env.yml' : null)
        container 'evezeyl/r_assemblage:latest'

        label 'process_high_memory'

        input:
        path(quast_reports)
	path(completeness_reports)
	path(coverage_reports)

        output:
        path "*"
	path "quast_comparison_report.txt", emit: quast_report_ch
	path "completeness_reports.txt", emit: completeness_report_ch
	path "il_coverage_reports.txt", emit: il_coverage_report_ch
        path "np_coverage_reports.txt", emit: np_coverage_report_ch

        script:
        """
        Rscript $baseDir/bin/merge_reports.R
        """
}
