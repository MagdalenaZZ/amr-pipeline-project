# Solution Architecture – AMR Pipeline

This document outlines the high-level architecture for executing the AMR analysis pipeline on a modern HPC and data lakehouse platform.

---

## 🧱 Components

### 1. **Object Storage (Raw Data Layer)**
- Stores raw Illumina and Nanopore FASTQ files
- Accessible via POSIX paths or S3-compatible APIs (e.g., MinIO, AWS S3)

### 2. **Ingest & Analysis (Nextflow + SLURM)**
- Pipeline is orchestrated by **Nextflow**
- Jobs scheduled and parallelized using **SLURM**
- Containerized environment ensures reproducibility (Docker)

### 3. **Lakehouse Layer**
- Outputs (e.g., AMR tables, QC reports) stored in **Parquet** format
- Readable by SQL engines (e.g., DuckDB, Trino, Spark)
- Serves as a foundation for scalable analytics and reporting

### 4. **API Layer**
- REST or GraphQL service exposes aggregated AMR results
- Enables integration with dashboards or alerting systems

### 5. **CI/CD & Container Registry**
- GitHub Actions automates tests and validation
- Container images pushed to GitHub Container Registry or DockerHub

---

## 🔄 Data Flow

1. Upload raw FASTQ to object storage
2. Trigger analysis pipeline on SLURM cluster
3. Pipeline produces AMR annotation results
4. Results converted to structured data (e.g., JSON, CSV, Parquet)
5. Stored in a lakehouse layer for downstream consumption

---

## ✅ Justification

- **Nextflow** enables scalable, reproducible workflows with native container support
- **SLURM** provides efficient resource management on HPC
- **Parquet + SQL** supports fast, schema-aware querying over AMR results
- Modular design allows future extensions (e.g., additional organisms, ML predictions)

---

*Diagram available in `architecture_diagram.png`*

 
