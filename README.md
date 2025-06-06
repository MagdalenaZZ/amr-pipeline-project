# amr-pipeline-project


# AMR Analysis Pipeline

## Overview
This repo contains a reproducible workflow for AMR detection from bacterial genome sequences using both Illumina and Nanopore data.

## Contents
- `workflow/`: Main pipeline (Nextflow/Snakemake) with configs
- `documentation/`: Reports, diagrams, pitch deck
- `results/`: Output directories per platform
- `slurm/`: SLURM example scripts
- `scripts/`: Helper tools

## How to Run
1. Pull required containers: `docker pull ...` or build from Dockerfile
2. Run the pipeline:
```bash
nextflow run workflow/main.nf -profile docker,slurm



