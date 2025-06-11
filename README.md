# AMR Pipeline Project

This project implements a reproducible bioinformatics pipeline for antimicrobial resistance (AMR) profiling from bacterial whole-genome sequencing data. It supports both Illumina and Nanopore datasets and is built for execution on an HPC platform using **Nextflow** with **Docker**, **SLURM**, and object storage integration.

---

##  Objectives

* Perform quality control, assembly, and AMR annotation on mock bacterial genomes
* Compare AMR profiles between Illumina and Nanopore platforms
* Export results in a structured format suitable for downstream analysis
* Develop a scalable architecture for deployment in a lakehouse-based data platform

---

##  Project Structure

```text

.
├── api					# FastAPI mock service
│   ├── __pycache__
│   │   └── main.cpython-310.pyc
│   └── main.py
├── assets				# Templates, logos and other assets
│   ├── email_template.html
│   └── logo_light.png
├── bin					# Scripts and functions
│   ├── export_to_parquet.py
│   ├── make_input_sample_sheets.py
│   └── run_duckdb_query.py
├── conf				# Configuration files
│   ├── aws.config
│   ├── base.config
│   ├── local.config
│   ├── params.config
│   └── test.config
├── data				# Example data - no real data files provided
│   ├── example_sample_sheet.Illumina.csv
│   └── example_sample_sheet.Nanopore.csv
├── Docker				# Example repo for building docker images the pipeline needs
│   └── amrfinder
│       └── v.4.0.23
│           └── Dockerfile
├── documentation			# Requested documentation
│   ├── AMR.md
│   ├── architecture_diagram.png
│   ├── ARCHITECTURE.md
│   ├── LLM_USAGE.md
│   ├── NEXTFLOW_documentation.md
│   └── PITCH.pptx
├── environment.yml			# File for building a conda environment with the right dependencies
├── lakehouse				# AMR results in tabluar format, and example sql query
│   ├── amr_results.csv
│   ├── amr_results.parquet
│   └── query_amr.sql
├── LICENSE
├── main.nf				# Nextflow main function entrypoint 
├── modules				# Mockup of modules structure for additional functions
│   ├── local_function
│   │   └── main.nf
│   └── tools
│       └── tool1
│           ├── main.nf
│           └── meta.yml
├── nextflow.config			# Example config
├── README.md
├── requirements-dev.txt		# Required packages for development of this package
├── results				# Example results, no sequence data appended
│   ├── funcscan
│   │   ├── abricate.ill.tsv
│   │   ├── abricate.np.tsv
│   │   ├── AMRFinderPlus.ill.tsv
│   │   └── AMRFinderPlus.np.tsv
│   ├── illumina
│   │   ├── assembly.fasta
│   │   ├── assembly.fasta.fai
│   │   └── multiqc_report.html
│   └── nanopore
│       ├── filtered_contigs.fasta
│       └── filtered_contigs.fasta.fai
├── slurm				# SLURM job submission example for use on local HPC
│   └── example_submit.sh
├── tests				# Pytest-based unit tests and test data (no real tests or test data provided)
│   ├── __init__.py
│   ├── config
│   │   └── test.config
│   ├── data
│   │   ├── example_sample_sheet.Illumina.csv
│   │   └── example_sample_sheet.Nanopore.csv
│   ├── test_pipeline.py
│   └── test_utils.py
├── work				# Nextflow temporary files
└── workflows				# Nextflow pipeline modules and config
    ├── CHANGELOG.md
    ├── CITATIONS.md
    ├── config
    ├── main.nf
    └── subworkflows
        └── local
            └── utils
                └── email_sender.nf


```

---

## 🐍 Environment Setup

```bash
conda env create -f environment.yml
conda activate amr-pipeline-project
```

---

##  Running the Pipeline

This pipeline processes Illumina and/or Nanopore sequencing data to generate assembled genomes and perform AMR analysis. It automatically detects the platform type (short-read or long-read) per sample and routes them through appropriate sub-workflows.

###  Requirements

* **Nextflow** `>=22.10.0`
* **Docker** (or Singularity)
* Optional: **SLURM** if using on HPC
* Internet access (for container pulls and downloads)

###  Input Format

Create a tab-delimited samplesheet:

```tsv
ID	R1	R2	LongFastQ	Fast5	GenomeSize
ERR044595	https://..._R1.fastq.gz	https://..._R2.fastq.gz	NA	NA	5.6m
mysample	NA	NA	https://...nanopore.fastq.gz	NA	5.6m
```

* `R1/R2` = paired-end Illumina reads
* `LongFastQ` = single FASTQ file for Nanopore
* `GenomeSize` = optional estimated genome size (e.g. `5.6m`)

Examples are provided in the folder data/

### Run Example

```bash
nextflow run workflows/main.nf \
  --input_samplesheet tests/data/example_sample_sheet.Illumina.csv \
  --outdir results \
  -profile docker
```

###  Pipeline Steps

1. Preprocessing: `bin/make_input_sample_sheets.py`
2. Illumina -> `wf-paired-end-illumina-assembly`
3. Nanopore -> `wf-bacterial-genomes`
4. Contigs -> `nf-core/funcscan`

The pipeline is comprehensively described in documentation/NEXTFLOW_documentation.md

###  SLURM Usage Example

```bash
nextflow run workflows/main.nf \
  --input_samplesheet tests/data/example_sample_sheet.Illumina.csv \
  --outdir results \
  -profile docker,slurm
```

---

##  LLM Usage

See [`documentation/LLM_USAGE.md`](documentation/LLM_USAGE.md) for details on how AI tools (e.g., ChatGPT) were used to assist with this project.

---

##  License

This project uses an open-source license (e.g., MIT or GPLv3). See `LICENSE` for full terms.
(not implemented, as this is a dummy project, not intended for use)


