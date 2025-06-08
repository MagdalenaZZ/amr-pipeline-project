#!/usr/bin/env nextflow

nextflow.enable.dsl = 2

/*
  MASTER PIPELINE:
  Runs either a short-read or long-read assembly pipeline per sample based on input,
  then sends the resulting contigs to funcscan.
*/

params.input_samplesheet = "samplesheet.tsv"
params.script_folder     = "scripts"
params.outdir            = "results"
params.profile           = "docker"

workflow {

    Channel.fromPath(params.input_samplesheet)
           .set { input_samplesheet_ch }

    // Step 1: Preprocess the input samplesheet
    preprocess_inputs(input_samplesheet_ch)

    // Step 2: Route based on type
    .branch {
        illumina: it.type == 'illumina'
        nanopore: it.type == 'nanopore'
    }
    .set { sample_branches }

    sample_branches.illumina | run_illumina()
    sample_branches.nanopore | run_nanopore()

    // Step 3: Merge all generated contigs and run funcscan
    (run_illumina.out.contigs, run_nanopore.out.contigs)
        .flatten()
        .set { contigs_ch }

    run_funcscan(contigs_ch)
}

// --- Process 1: Preprocess Input Samplesheet ---
process preprocess_inputs {
    tag "$input_samplesheet"
    publishDir "${params.outdir}/preprocessed", mode: 'copy'

    input:
    path input_samplesheet

    output:
    path "*illumina*.csv", emit: illumina_csv
    path "*bacterial-genomes*.csv", emit: nanopore_csv
    path "*funcscan*.csv", emit: funcscan_csv
    tuple val(type), val(sample_id), path(".")

    script:
    """
    python ${params.script_folder}/make_input_sample_sheets.py \
        --input $input_samplesheet \
        --output_dir ./

    for f in *.csv; do
        if [[ "$f" == *illumina* ]]; then
            echo -e "illumina\t\$(cut -f1 \$f | tail -n +2)" > illumina_samples.tsv
        elif [[ "$f" == *bacterial-genomes* ]]; then
            echo -e "nanopore\t\$(cut -f1 \$f | tail -n +2)" > nanopore_samples.tsv
        fi
    done
    """
}

// --- Process 2: Run Illumina Assembly Workflow ---
workflow run_illumina {
    take:
    tuple val(type), val(sample_id), path(meta_dir)

    main:
    process run_illumina_pipeline {
        tag "$sample_id"
        publishDir "${params.outdir}/illumina/${sample_id}", mode: 'copy'

        input:
        val sample_id
        path meta_dir

        output:
        path "data/Illumina/assembly.fa", emit: contigs

        script:
        """
        nextflow run bacterial-genomics/wf-paired-end-illumina-assembly \
            -r v2.3.0 \
            -profile ${params.profile} \
            --input \${meta_dir}/new-fastq-dir \
            --outdir results/illumina/${sample_id} \
            --work-dir work/illumina/${sample_id} \
            --checkm2_db /tmp/nxf_work/REFERENCES/checkm2_database.tar.gz \
            --mash_db /tmp/nxf_work/REFERENCES/refseq.genomes.k21s1000.msh \
            --blast_db /tmp/nxf_work/REFERENCES/16S_ribosomal_RNA.tar.gz \
            --kraken1_db /tmp/nxf_work/REFERENCES/minikraken_20171019_8GB.tgz \
            --kraken2_db /tmp/nxf_work/REFERENCES/k2_standard_08gb_20231009.tar.gz \
            --cat_db /tmp/nxf_work/REFERENCES/card-data.tar.bz2
        """
    }
}

// --- Process 3: Run Nanopore Assembly Workflow ---
workflow run_nanopore {
    take:
    tuple val(type), val(sample_id), path(meta_dir)

    main:
    process run_nanopore_pipeline {
        tag "$sample_id"
        publishDir "${params.outdir}/nanopore/${sample_id}", mode: 'copy'

        input:
        val sample_id
        path meta_dir

        output:
        path "data/Nanopore/filtered_contigs.fasta", emit: contigs

        script:
        """
        nextflow run epi2me-labs/wf-bacterial-genomes \
            --fastq \${meta_dir}/wf-bacterial-genomes-demo/isolates_fastq \
            --isolates \
            --sample_sheet \${meta_dir}/wf-bacterial-genomes-sample_sheet.csv \
            --outdir results/nanopore/${sample_id} \
            --work-dir work/nanopore/${sample_id}
        """
    }
}

// --- Process 4: Run Funcscan ---
workflow run_funcscan {
    take:
    path contigs

    main:
    process run_funcscan_pipeline {
        tag "$contigs.name"
        publishDir "${params.outdir}/funcscan/${contigs.name}", mode: 'copy'

        input:
        path contigs

        output:
        path "funcscan_npass_out/*"

        script:
        """
        nextflow run nf-core/funcscan \
            -profile ${params.profile} \
            --input samplesheet.funcscan.csv \
            --outdir funcscan_npass_out \
            --work-dir work/funcscan/${contigs.name} \
            --run_amp_screening
        """
    }
}

