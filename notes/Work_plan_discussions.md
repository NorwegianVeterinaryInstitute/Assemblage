# 2022-07-21
Objectives

- [ ] for research 
	- [ ] framework to do everything - select out what you do not want 

- [ ] ==Cases of usages== - we need to develop that 


- [ ] Modifying / adapting should be easy 
- [ ] Assemblies - different methods -> different models - different models assemblies ...and then compare - an idea for the feature 



## PreQuality check 
- fastqc + multiqc 
- Replacement - more informative for fastqc and multiqc ? (@Haukon add the 2 ref you mention)
- Kraken - > contamination detection -> database ?
	- level contaminant - ==? 5% accepted - threshold== - ? choose the best hit - > seems so --> flag those with more than 5 % 
		- flag = attention -> required 
	- database - update --- the small database
		- make a path for the user to supply if user want - default and user can change 
	- summarize nb reads - ie species level 
- trimming - ? trimgalore  - report 
- fastqc + multiqc (post trimming)
	- option to get the fastqc report 


- [fastP](LINK) ? - still in development .... but appear popular - trimming an quality control ? - and has support for long reads 
> reduce complexity of pipeline 
> ? no contaminant info 


- mash distance -> sketching reads sets -> with MDS plot in report - homogeneity/divergence between isolates under - study 
	- ? easier to see contaminants 
- 
> why to do that
> Report need to be understandable - clear might indicate ... 
> How can we convey the different possibilities ?
> 	reasons Håkons wants different assemblers ...
> 	missassemblies ...
> 

? traditional track - new popular track 
hum paper idea - see other notes 


nanopore -> no trimming - filtering short reads - filtlong - then cando assemblies 

## Assembly 
- unicycler - based spades --> @Eve have a look at the wiki 
- shovill - based spades + circulator 
? other hybrid assembler - type ? overlapp consensus that can be good 
- 
- ? tricycler (idea) - makes consensus of different assemblies (based on clustering) - problem interactive and not pipeline friendly 
- ? another assembler ... 
- ? skesa 
maybe re-read from @Castro2020  

Hybrid assemblies - in term - issues to discuss 


? polishing - nucleotides .... is it worth it 

### Postquality 
- checkM 
	- completness genome ? from reads 
- coverage 


Guide to bacterial genome assembly, created by Ryan Wick:
https://github.com/rrwick/Trycycler/wiki/Guide-to-bacterial-genome-assembly


![[GITS_WORK/Assemblage/Work_plan_discussions 2022-07-21_14.15.31.excalidraw]]

