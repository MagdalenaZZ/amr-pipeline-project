# Demo commands

# Bygg miljon
conda env create -f environment.yml
conda activate amr-pipeline-project

# Kor huvudflodet
nextflow run workflows/main.nf --input_samplesheet tests/data/example_sample_sheet.Illumina.csv --outdir demo_results

# Bygg en docker container
docker build -t amrfinder:v.4.0.23 -f Docker/amrfinder/v.4.0.23/Dockerfile .
open /Applications/Docker.app

# Exportera och bygg filen lakehouse/amr_results.parquet fran fejk data lakehouse/amr_results.csv
python bin/export_to_parquet.py

# En enkel sql fraga till databasen 
python bin/run_duckdb_query.py




