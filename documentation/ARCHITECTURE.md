# Solution Architecture – AMR Pipeline

This document outlines the high-level architecture for executing the AMR analysis pipeline on a modern HPC and data lakehouse platform.

---

## 🧱 Components

### 1. **Object Storage (Raw Data Layer)**

*Object storage is the digital filing cabinet where all the raw sequencing data and metadata are securely kept. This enables reliable access and archiving for downstream analysis.*

* Stores raw Illumina and Nanopore FASTQ files
* Accessible via POSIX paths or S3-compatible APIs (e.g., MinIO, AWS S3)
* Stores metadata such as submission site and pseudonymized patient identifier
* Configured with safety and security best practices to protect sensitive data, including:

  * Encryption at rest and in transit
  * Access control via IAM policies or equivalent
  * Audit logging and segregation of patient identifiers

### 2. **Ingest & Analysis (Nextflow + SLURM)**

*This is the brain of the pipeline—where raw data is turned into meaningful biological results through quality control, genome assembly, and resistance profiling.*

* Pipeline is orchestrated by **Nextflow**
* Jobs scheduled and parallelized using **SLURM**, but for testing AWS Batch, EC2, and S3 have also been used
* Containerized environment ensures reproducibility (Docker)
* Initial QC evaluates read quality, contamination, and species correctness
* Follows with genome assembly, annotation, and AMR profiling
* Uses high-performing AMR detection tools with \~99% sensitivity
* Reports displaying relevant results with supporting evidence (e.g., read support, tool agreement), and immediately e-mailed to submitter
* Pipelines are validated using nf-core standards; schema and structural validation are performed on outputs
* In urgent clinical scenarios, a 'fast-path' version of the pipeline may run on partial reads to deliver early insights (within 5-7 hours) to inform clinical decisionmaking for critically ill patients

### 3. **Lakehouse Layer**

*This is where structured, analysis-ready data lives—organized in a format that allows lightning-fast queries and deep dives into trends and summaries.*

* Outputs (e.g., AMR tables, QC reports) stored in **Parquet** format
* Readable by SQL engines (e.g., DuckDB, Trino, Spark)
* Serves as a foundation for scalable analytics and reporting
* DuckDB is embedded within the API for lightweight interactive queries; Trino or Spark can be used for larger-scale access

### 4. **API Layer**

*Easier analysis access with an API Layer. Having an API layer makes it much easier for researchers to make reports and ask advanced questions of the data, like “How many samples of Klebsiella with carbapenem resistance did we find in KI in 2023?”*

* REST or GraphQL service exposes aggregated AMR results
* Enables integration with dashboards or alerting systems
* Allows researchers to query and explore the data flexibly
* Interacts directly with Parquet files via embedded DuckDB, or via distributed engines like Trino or Spark in high-throughput scenarios

### 5. **CI/CD & Container Registry**

*This is the automation engine that ensures everything runs smoothly and correctly every time, without manual intervention. It validates the pipeline and packages everything into portable containers.*

* GitHub Actions automates tests and validation of both pipelines and APIs
* Container images pushed to GitHub Container Registry or DockerHub
* Includes integration tests, mocked data runs, and schema enforcement

---

## 🔄 Data Flow

1. Samples are collected from patients, either in active care or postmortem
2. Sequencing performed rapidly using MinION, providing real-time reads
3. Results interpreted within hours and may guide treatment decisions (e.g., antibiotic switch, isolation)
4. Raw FASTQ files and metadata are uploaded to secure object storage
5. Patient DNA is filtered out before further analysis
6. Nextflow pipeline is triggered on SLURM cluster or AWS
7. QC steps assess quality, contamination, and correct species
8. Genome assembly, annotation, and AMR profiling follow
9. Evidence is collected into reports, e.g., read support, prediction congruence
10. Structured results are generated (JSON, CSV, Parquet)
11. Parquet files stored in DuckDB within the lakehouse layer
12. API layer enables querying, analysis, and reporting via DuckDB or Trino

---

🔬 Validation, Testing, and Maintenance

*This system ensures the pipeline remains accurate, reliable, and maintainable over time.*

* Unit testing verifies that individual components and scripts behave as expected
* Integration testing ensures modules work together correctly, especially across container boundaries
* End-to-end testing mimics full real-world workflows using mocked or historical data to catch complex issues
* Regular updates to tools and reference databases are automated and version-controlled
* Automatic cleanup routines archive or delete obsolete intermediate files and datasets to manage storage efficiently

---

## ✅ Justification

* **Nextflow** enables scalable, reproducible workflows with native container support
* **SLURM** provides efficient resource management on HPC
* **Parquet + SQL** supports fast, schema-aware querying over AMR results
* Modular design allows future extensions (e.g., additional organisms, ML predictions)
* The architecture supports elastic scaling via SLURM on-premises and AWS Batch in the cloud, allowing flexible resource allocation based on queue size and compute demands

---

*Diagram available in `architecture_diagram.png`, summarizing the above flow and system interactions.*

