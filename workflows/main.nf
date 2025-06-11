#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*
  MASTER PIPELINE:
  Runs either a short-read or long-read assembly pipeline per sample based on input,
  then sends the resulting contigs to funcscan.
*/

params.input_samplesheet = "samplesheet.tsv"
params.script_folder     = "bin"
params.outdir            = "results"
params.profile           = "docker"

// --- CHANNEL SETUP ---

input_samplesheet_ch = Channel.fromPath(params.input_samplesheet)
make_script_ch = Channel.fromPath("${params.script_folder}/make_input_sample_sheets.py")

preprocess_input_bundle = input_samplesheet_ch.combine(make_script_ch)

illumina_ch = input_samplesheet_ch.filter { it.toString().contains("illumina") }
nanopore_ch = input_samplesheet_ch.filter { it.toString().contains("bacterial-genomes") }

// --- MAIN WORKFLOW ---

workflow {

    preprocess_inputs(preprocess_input_bundle)

    run_illumina(illumina_ch)
    run_nanopore(nanopore_ch)

    run_funcscan(
        run_illumina.out.contigs.combine(run_nanopore.out.contigs).flatten()
    )
}

// --- PROCESS: Preprocess Input Samplesheet ---

process preprocess_inputs {
    tag "$input_samplesheet"
    publishDir "${params.outdir}/preprocessed", mode: 'copy'

    input:
    tuple path(input_samplesheet), path(script_path)

    output:
    path "*illumina*.csv", emit: illumina_csv
    path "*bacterial-genomes*.csv", emit: nanopore_csv
    path "*funcscan*.csv", emit: funcscan_csv
    path "*.tsv"

    script:
    """
    python $script_path \\
        --input $input_samplesheet
    """
}

// --- WORKFLOW: Run Illumina Assembly ---

workflow run_illumina {
    take:
    input_ch

    main:
    run_illumina_pipeline(input_ch)

    emit:
    contigs = run_illumina_pipeline.out.contigs
}

process run_illumina_pipeline {
    tag "$input"
    publishDir "${params.outdir}/illumina/", mode: 'copy'

    input:
    path input

    output:
    path "data/Illumina/assembly.fa", emit: contigs

    script:
    """
    nextflow run bacterial-genomics/wf-paired-end-illumina-assembly \\
        -r v2.3.0 \\
        -profile ${params.profile} \\
        --input \${input}/new-fastq-dir \\
        --outdir results/illumina/ \\
        --work-dir work/illumina/ \\
        --checkm2_db /tmp/nxf_work/REFERENCES/checkm2_database.tar.gz \\
        --mash_db /tmp/nxf_work/REFERENCES/refseq.genomes.k21s1000.msh \\
        --blast_db /tmp/nxf_work/REFERENCES/16S_ribosomal_RNA.tar.gz \\
        --kraken1_db /tmp/nxf_work/REFERENCES/minikraken_20171019_8GB.tgz \\
        --kraken2_db /tmp/nxf_work/REFERENCES/k2_standard_08gb_20231009.tar.gz \\
        --cat_db /tmp/nxf_work/REFERENCES/card-data.tar.bz2
    """
}

// --- WORKFLOW: Run Nanopore Assembly ---

workflow run_nanopore {
    take:
    input_ch

    main:
    run_nanopore_pipeline(input_ch)

    emit:
    contigs = run_nanopore_pipeline.out.contigs
}

process run_nanopore_pipeline {
    tag "$input"
    publishDir "${params.outdir}/nanopore/", mode: 'copy'

    input:
    path input

    output:
    path "data/Nanopore/filtered_contigs.fasta", emit: contigs

    script:
    """
    nextflow run epi2me-labs/wf-bacterial-genomes \\
        --fastq \${input}/wf-bacterial-genomes-demo/isolates_fastq \\
        --isolates \\
        --sample_sheet \${input}/wf-bacterial-genomes-sample_sheet.csv \\
        --outdir results/nanopore/ \\
        --work-dir work/nanopore/
    """
}

// --- WORKFLOW: Run Funcscan ---

workflow run_funcscan {
    take:
    contigs_ch

    main:
    run_funcscan_pipeline(contigs_ch)
}

process run_funcscan_pipeline {
    tag "$contigs.name"
    publishDir "${params.outdir}/funcscan/${contigs.name}", mode: 'copy'

    input:
    path contigs

    output:
    path "funcscan_npass_out/*"

    script:
    """
    nextflow run nf-core/funcscan \\
        -profile ${params.profile} \\
        --input samplesheet.funcscan.csv \\
        --outdir funcscan_npass_out \\
        --work-dir work/funcscan/${contigs.name} \\
        --run_arg_screening
    """
}

