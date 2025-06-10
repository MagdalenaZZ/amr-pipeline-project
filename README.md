# AMR Pipeline Project

This project implements a reproducible bioinformatics pipeline for antimicrobial resistance (AMR) profiling from bacterial whole-genome sequencing data. It supports both Illumina and Nanopore datasets and is built for execution on an HPC platform using **Nextflow** with **Docker**, **SLURM**, and object storage integration.

---

## 🚀 Objectives

* Perform quality control, assembly, and AMR annotation on mock bacterial genomes
* Compare AMR profiles between Illumina and Nanopore platforms
* Export results in a structured format suitable for downstream analysis
* Develop a scalable architecture for deployment in a lakehouse-based data platform

---

## 📆 Project Structure

```text
amr-pipeline-project/
├── api/                        # FastAPI mock service
│   ├── __pycache__/
│   └── main.py
├── data/                       # (Optional) Raw input data or instructions
├── documentation/             # Reports, diagrams, pitch deck
│   ├── AMR.md
│   ├── ARCHITECTURE.md
│   ├── architecture_diagram.png
│   ├── LLM_USAGE.md
│   └── PITCH.pptx
├── environment.yml            # Conda environment setup
├── input/                     # Example input samplesheets
│   └── example_sample_sheet.csv
├── lakehouse/                 # AMR results in tabular formats
│   ├── amr_results.csv
│   ├── amr_results.parquet
│   └── query_amr.sql
├── LICENSE
├── main.nf                    # Master Nextflow pipeline entrypoint
├── nextflow.config
├── README.md
├── requirements-dev.txt       # (Optional) pip-based environment config
├── results/                   # Output from Nextflow workflow
│   ├── funcscan/
│   ├── illumina/
│   │   └── multiqc_report.html
│   └── nanopore/
├── scripts/                   # Helper scripts
│   ├── export_to_parquet.py
│   ├── make_input_sample_sheets.py
│   └── run_duckdb_query.py
├── slurm/                     # SLURM job submission example
│   └── example_submit.sh
├── tests/                     # Pytest-based unit tests
│   ├── __init__.py
│   ├── data/
│   ├── test_pipeline.py
│   └── test_utils.py
├── work/                      # Nextflow temporary files
└── workflow/                  # Nextflow pipeline modules and config
    ├── config/
    │   └── nextflow.config
    └── main.nf
```

---

## 🐍 Environment Setup

```bash
conda env create -f environment.yml
conda activate amr-pipeline
```

---

## 🛠️ Running the Pipeline

This pipeline processes Illumina and/or Nanopore sequencing data to generate assembled genomes and perform AMR analysis. It automatically detects the platform type (short-read or long-read) per sample and routes them through appropriate sub-workflows.

### 🔧 Requirements

* **Nextflow** `>=22.10.0`
* **Docker** (or Singularity)
* Optional: **SLURM** if using on HPC
* Internet access (for container pulls and downloads)

### 📁 Input Format

Create a tab-delimited samplesheet:

```tsv
ID	R1	R2	LongFastQ	Fast5	GenomeSize
ERR044595	https://..._R1.fastq.gz	https://..._R2.fastq.gz	NA	NA	2.8m
mysample	NA	NA	https://...nanopore.fastq.gz	NA	5.6m
```

* `R1/R2` = paired-end Illumina reads
* `LongFastQ` = single FASTQ file for Nanopore
* `GenomeSize` = optional estimated genome size (e.g. `5.6m`)

### 🔮 Run Example

```bash
nextflow run workflow/main.nf \
  --input_samplesheet input/example_sample_sheet.csv \
  --outdir results \
  -profile docker
```

### 🔄 Pipeline Steps

1. Preprocessing: `scripts/make_input_sample_sheets.py`
2. Illumina -> `wf-paired-end-illumina-assembly`
3. Nanopore -> `wf-bacterial-genomes`
4. Contigs -> `nf-core/funcscan`

### 🌧️ SLURM Usage Example

```bash
nextflow run workflow/main.nf \
  --input_samplesheet input/example_sample_sheet.csv \
  --outdir results \
  -profile docker,slurm
```

---

## 🤖 LLM Usage

See [`documentation/LLM_USAGE.md`](documentation/LLM_USAGE.md) for details on how AI tools (e.g., ChatGPT) were used to assist with this project.

---

## 📝 License

This project uses an open-source license (e.g., MIT or GPLv3). See `LICENSE` for full terms.

