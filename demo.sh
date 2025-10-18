# Demo commands


# Referenser
aws s3 ls s3://nf-core-data/REFERENCES/

# Data
cat data/example_sample_sheet.Illumina.csv
cat data/example_sample_sheet.Nanopore.csv

# Bygg miljon
conda env create -f environment.yml
conda activate amr-pipeline-project

# Bygg en docker container
docker build -t amrfinder:v.4.0.23 -f Docker/amrfinder/v.4.0.23/Dockerfile .
open /Applications/Docker.app
cat tmp.file| awk '{print $1"\t"$2"\t"$4" "$5" "$6}' | grep amr

# Kor huvudflodet
nextflow run workflows/main.nf --input_samplesheet tests/data/example_sample_sheet.Illumina.csv --outdir demo_results

# Exportera och bygg filen lakehouse/amr_results.parquet fran fejk data lakehouse/amr_results.csv
python bin/export_to_parquet.py

# En enkel sql fraga till databasen 
python bin/run_duckdb_query.py

# Start the API layer 
uvicorn api.main:app --reload

# Navigate to the URL to see the results
http://localhost:8000/api/amr-summary 

# Testning
cat .github/workflows/test.yml

