process MULTIQC_PRE {
        publishDir "${params.out_dir}/01_QC/03_multiqc_reports", pattern: "*html", mode: "copy", saveAs: {"MultiQC_pre_trimming_report.html"}

        input:
        file("*")

        output:
        file("*")

        """
        multiqc *.zip
        """
}

process MULTIQC_POST {
        publishDir "${params.out_dir}/01_QC/03_multiqc_reports", pattern: "*html", mode: "copy", saveAs: {"MultiQC_post_trimming_report.html"}

        input:
        file("*")

        output:
        file("*")

        """
        multiqc *.zip
        """
}
