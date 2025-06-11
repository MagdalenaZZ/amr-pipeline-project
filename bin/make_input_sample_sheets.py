import pandas as pd
import os
import argparse

"""
This script generates derived sample sheet files for downstream Nextflow pipelines,
starting from a unified master sample sheet describing multiple sequencing samples.

Purpose:
--------
The script supports workflows for:
1. Illumina short-read assembly.
2. Nanopore long-read assembly.
3. Functional annotation via FuncScan.

It identifies the type of sequencing data available for each sample and creates appropriate
samplesheet files for each analysis branch, ensuring downstream tools receive the correct input format.

Inputs:
-------
- A master sample sheet (CSV) with the following columns:
    ID, R1, R2, LongFastQ, Fast5, GenomeSize
  - R1/R2 should contain paths or URLs to paired-end Illumina reads.
  - LongFastQ should contain paths or URLs to long-read Nanopore data.

- An output directory where the derived sample sheets and folders will be created.

Outputs:
--------
1. data/Illumina/{ID}_assembly.fa      (intended path for Illumina assemblies)
2. data/Nanopore/{ID}_filtered_contigs.fasta (intended path for Nanopore assemblies)
3. illumina_samplesheet.csv            (for Illumina assembly workflow)
4. nanopore_samplesheet.csv            (for Nanopore assembly workflow)
5. samplesheet.funcscan.csv            (for FuncScan workflow)
"""

def make_output_dirs(base_dir):
    long_dir = os.path.join(base_dir, 'data/Nanopore')
    short_dir = os.path.join(base_dir, 'data/Illumina')
    os.makedirs(long_dir, exist_ok=True)
    os.makedirs(short_dir, exist_ok=True)
    return long_dir, short_dir

def generate_sample_sheets(input_csv,base_dir):
    df = pd.read_csv(input_csv, sep=None, engine='python')

    illumina_rows = []
    nanopore_rows = []
    funcscan_rows = []

    long_dir, short_dir = make_output_dirs(base_dir)

    for _, row in df.iterrows():
        sample_id = row['ID']

        # Process Illumina samples
        if pd.notna(row['R1']) or pd.notna(row['R2']):
            illumina_rows.append({
                'sample': sample_id,
                'fastq_1': row['R1'],
                'fastq_2': row['R2']
            })
            contig_out = os.path.join(short_dir, f'{sample_id}_assembly.fa')

        # Process Nanopore samples
        if pd.notna(row['LongFastQ']):
            nanopore_rows.append({
                'sample': sample_id,
                'fastq_path': row['LongFastQ']
            })
            contig_out = os.path.join(long_dir, f'{sample_id}_filtered_contigs.fasta')

        # Funcscan sample
        if pd.notna(row['LongFastQ']):
            funcscan_rows.append({'ID': sample_id, 'assembly': contig_out})
        elif pd.notna(row['R1']):
            funcscan_rows.append({'ID': sample_id, 'assembly': contig_out})

    if illumina_rows:
        pd.DataFrame(illumina_rows).to_csv(os.path.join(base_dir, 'illumina_samplesheet.csv'), index=False)

    if nanopore_rows:
        pd.DataFrame(nanopore_rows).to_csv(os.path.join(base_dir, 'nanopore_samplesheet.csv'), index=False)

    if funcscan_rows:
        pd.DataFrame(funcscan_rows).to_csv(os.path.join(base_dir, 'samplesheet.funcscan.csv'), index=False)

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Generate input sample sheets for downstream workflows.')
    parser.add_argument('--input', required=True, help='Input master sample sheet (CSV)')
    args = parser.parse_args()
    base_dir = os.path.dirname(os.path.abspath(args.input))
    
    generate_sample_sheets(args.input,base_dir)


