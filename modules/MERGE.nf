process MERGE_REPORTS {
        conda (params.enable_conda ? './assets/r_env.yml' : null)
        container 'evezeyl/r_docker:latest'

        input:
        path(reports)

        output:
        path "*"
	path "kraken_reports.txt", emit: kraken_report
	path "coverage_reports.txt", emit: coverage_report

        script:
        """
        Rscript $baseDir/bin/merge_data.R
        """
}
