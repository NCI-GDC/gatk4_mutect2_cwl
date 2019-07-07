#!/usr/bin/env cwl-runner

cwlVersion: v1.0

doc: |
    GATK4.1.2 Alignment artifacts filtration workflow

class: Workflow

inputs:
  java_heap: string
  output_prefix: string
  reference:
    type: File
    secondaryFiles: [.fai, ^.dict]
  reference_image: File
  input_vcf:
    type: File
    secondaryFiles: [.tbi]
  bam_outs:
    type: File[]
    secondaryFiles: [^.bai]

outputs:
  alignment_artifacts_filtered_vcf:
    type: File
    outputSource: filter_alignment_artifacts/alignment_artifacts_filtered_vcf

steps:
  gather_reassembly_bamfiles:
    run: ../../tools/filter_alignment_artifacts/gather_bamfiles.cwl
    in:
      java_heap: java_heap
      output_prefix: output_prefix
      reference: reference
      bam_outs: bam_outs
    out: [merged_out_bam]

  sort_out_bam:
    run: ../../tools/filter_alignment_artifacts/sort_sam.cwl
    in:
      java_heap: java_heap
      unsorted_bam: gather_reassembly_bamfiles/merged_out_bam
      output_prefix: output_prefix
    out: [sorted_out_bam]

  index_out_bam:
    run: ../../tools/filter_alignment_artifacts/buildindex.cwl
    in:
      java_heap: java_heap
      input_bam_path: sort_out_bam/sorted_out_bam
    out: [sorted_bam_with_index]

  filter_alignment_artifacts:
    run: ../../tools/filter_alignment_artifacts/filter_alignment_artifacts.cwl
    in:
      java_heap: java_heap
      input_vcf: input_vcf
      reassembly_bam: index_out_bam/sorted_bam_with_index
      reference_image: reference_image
      output_prefix: output_prefix
    out: [alignment_artifacts_filtered_vcf]

