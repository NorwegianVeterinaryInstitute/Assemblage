# List of tools
This is a list of tools to consider for implementation in the Assemblage pipeline. Tools marked with a star are already implemented, or is highly likely to be implemented in the future.


## QC and Trimming
- FastQC/MultiQC ⭐
	- Basic QC of reads
	- Only useful if your data is very bad (Illumina data is very high quality these days...)
	- Doesn't necessarily provide useful metrics (perhaps GC% if significantly contaminated)
- Trimmomatic
	- Long been the gold-standard of trimming reads
	- Many options
	- A bit more troublesome to run due to run command being confusing
- Trim-Galore! ⭐
	- Babraham bioinformatics tool
	- Autodetects adapter sequences
	- Simple to use
	- Few settings to consider
- FastP ⭐
	- Relatively new tool, under development
	- Popular
	- Covers both QC and trimming in one tool
	- Support for long- and short reads
- Kraken ⭐
	- Useful for identifying potential contamination in the reads
	- Only useful if the contaminant is present in the database
		- But if the contaminant is present at a high level, maybe too many unclassified reads?
	- Useful to confirm the species you are working with
	- Report all hits, maybe flag specific genomes if contamination is present at above a specific threshold?
- Mash ⭐
	- NMDS of mash results to find outliers in the data, as described in the Panaroo pipeline (https://gtonkinhill.github.io/panaroo/#/quality/quality_control)
	- Very useful if reported with an interactive plot, outliers can be detected quickly


## Assembly
- SPAdes - [St. Petersburg genome assembler](https://github.com/ablab/spades) 
	- Under active development
	- Based on DeBruijn graphs
	- Regarded as the "gold standard" for microbial genome assembly
- [Unicycler](https://github.com/rrwick/Unicycler)
	- A wrapper around SPAdes
	- Based on DeBruijn graphs
	- Circularizes each replicon if possible
	- Automatically runs SPAdes several times with different k-mer sizes
	- Can also be used for hybrid/long-read assembly, as long as the depth of the long reads aren't too high
	- Pilon polishing removed from the newest version
- SKESA - [Strategic K-mer Extension for Scrupulous Assemblies](https://github.com/ncbi/SKESA#skesa---strategic-k-mer-extension-for-scrupulous-assemblies)
	- An NCBI-based pipeline
	- Based on DeBruijn graphs
	- Designed to create breaks at repeat regions in the genome
	- Can process reads directly from the SRA
- [Megahit](https://github.com/voutcn/megahit)
	- Ultra-fast and memory efficient NGS assembler
	- DeBruijn graph based
	- Optimized for metagenomes and larger genomes
- [Shovill](https://github.com/tseemann/shovill)
	- Wrapper around SPAdes
	- Based on DeBruijn graphs
	- Provides pre- and post processing around the assembly to reduce runtime
	- Can also use other assemblers instead of SPAdes, such as SKESA and Megahit