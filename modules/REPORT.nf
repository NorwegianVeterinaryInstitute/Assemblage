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
        Rscript $baseDir/bin/gen_report.R "draft" $params.genome_size $params.species_name
        """
}
