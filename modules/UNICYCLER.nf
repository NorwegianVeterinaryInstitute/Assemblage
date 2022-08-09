process UNICYCLER {
        publishDir "${params.out_dir}/02_ASSEMBLY/01_unicycler/", pattern: "*.fasta", mode: "copy"
        publishDir "${params.out_dir}/02_ASSEMBLY/01_unicycler/", pattern: "*unicycler.log", mode: "copy"

        tag "$datasetID"
	label 'bigmem'

        input:
        tuple val(datasetID), file(R1), file(R2)

        output:
        file("*")
        path("*.fasta"), emit: quast_ch
	tuple val(datasetID), path("*.fasta"), emit: assembly_ch

        """
        unicycler -1 $R1 -2 $R2 -o . --verbosity 2 --keep 2 --mode $params.mode --threads $task.cpus --min_fasta_length $params.min_fasta_length --depth_filter $params.depth_filter &> ${datasetID}_unicycler.log
        mv assembly.fasta ${datasetID}.fasta
        mv unicycler.log ${datasetID}_unicycler.log
	"""
}
