## Analysis workflow outline

You asked for a reproducible pipeline in nextflow or snakemake, with containers for doing quality control, assembly (Illumina and Nanopore), AMR-prediction and Results export.

I have created a Nextflow pipeline which does comprehensive quality control of reads, assemblies and content. It has best-practice assembly of Illumina and Nanopore data, and comprehensive AMR-predictions using several tools. In addition, you have species determination, filtering of human data, genome annotation, and some draft CI/CD testing etc. I did not yet implement comprehensive results export to parquet format, but included some draft code for the full architecture.

*Illumina assembly*

The Illumina assembly is done using the nextflow pipeline bacterial-genomics/wf-paired-end-illumina-assembly, which has been around for a few years and regularly updated. This workflow assembles bacterial isolate genomes from paired-end Illumina FastQ files. Post-assembly contig correction is performed, and a variety of quality assessment processes are recorded throughout the workflow. It can be used for all bacterial isolates (i.e., axenic, non-mixed cultures) sequenced with whole genome (WGS) or selective whole genome (SWGA) library preparation strategies. It is inappropriate for metagenomics analysis. The data files must be paired-end reads and can come from any Illumina sequencing instrument which generates a FastQ file format (e.g., iSeq, HiSeq, MiSeq, NextSeq, NovaSeq).
The tools integrated includes input validation, removal of human sequences, read cleaning, genome assembly with SPAdes, annotation with Bakta, taxonomic classification and comprehensive assembly assessment. Full schema here: https://github.com/bacterial-genomics/wf-paired-end-illumina-assembly/blob/main/docs/images/wf-paired-end-illumina-assembly_workflow.png

*Nanopore assembly*

Nanopore assembly is done with the ONT pipeline epi2me-labs/wf-bacterial-genomes, which is the sequencer supplied tool, so should be good quality, reliably built and comprehensively optimized and supported. In brief, this workflow will perform the following:
* De novo (or reference-based) assembly of bacterial genomes
* Annotation of regions of interest within the assembly
* Species identification and sequence typing (--isolates mode only)
* Identify genes and SNVs associated with AMR (--isolates mode only) 

*AMR predictions*

Funcscan is used to annotate the assembled contigs, through the parameter --run_arg_screening we select it to run a number of AMR analysis tools, and use hAMRonization to summarise the results.

Funcscan can provide a number of analyses:
* Annotation of assembled prokaryotic contigs with Prodigal, Pyrodigal, Prokka, or Bakta
* Screening contigs for antimicrobial peptide-like sequences with ampir, Macrel, HMMER, AMPlify
* Screening contigs for antibiotic resistant gene-like sequences with ABRicate, AMRFinderPlus, fARGene, RGI, DeepARG
* Screening contigs for biosynthetic gene cluster-like sequences with antiSMASH, DeepBGC, GECCO, HMMER
* Creating aggregated reports for all samples across the workflows with AMPcombi for AMPs, hAMRonization for ARGs, and comBGC for BGCs
* Software version and methods text reporting with MultiQC
Full workflow schema here: https://github.com/nf-core/funcscan/blob/master/docs/images/funcscan_metro_workflow.png


*Reflection*
I could have written my own nextflow pipeline from first principles, but it would probably not be as good as some of these which people have been working on for years. A pipeline like bacpaq already claims to be a nextflow bioinformatics best-practice pipeline for bacterial genomic analysis for short-reads (Illumina) and long-reads (Oxford Nanopore) sequencing data, and identifies AMR genes using RGI, AMRFinderPlus, ABRicate, abriTAMR, and Resfinder.  
So, I chose a somewhat arbirtary approach of doing a nextflow pipeline which implements three other nextflow pipelines, and some custom scripts to generate input files, do some unit and integration testing through github actions, and create database entries from results (not implemented). 
The time allotted was not enough to do custom test data, to do benchmarking, to implement comprehensive testing, or even get it reliably runing on AWS. With more time we could prioritise:
* Runtime reporting with nanopore for urgent cases 
* Custom reports for clinicians
* More careful benchmarking and tool selection
* Optimise compute, use of reference DBs etc to make the pipelines faster to run. When testing on both AWS and local, I  created a REFERENCE directory to keep up-to-date databases for the pipelines to run from:

```text
├── 16S_ribosomal_RNA.tar.gz
├── card-data.tar.bz2
├── checkm2_database.tar.gz
├── k2_standard_08gb_20231009.tar.gz
├── k2_standard_8gb_20210517.tar.gz
├── minikraken_20171019_8GB.tgz
├── refseq.genomes.k21s1000.msh
└ README.md   # Where the databases originate from, and how to update them
```
* In-house forks for easier development
* More careful separation of workflows for isolates vs clinical or environmental samples with higher impurity, and more effort put into supporting the type of samples you most often get.
* Integrated metadata handling, for example who requested the sample, its urgency, its origin, who to notify with important results, its consent policy and the data retention policy. These are things we most likely will always have to do in-house to fit with current demands and projects.



