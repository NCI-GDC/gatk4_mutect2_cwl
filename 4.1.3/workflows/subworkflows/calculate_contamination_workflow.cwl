#!/usr/bin/env cwl-runner

cwlVersion: v1.0

doc: |
    GATK4.1.2 Calculate tumor-normal contamination workflow

class: Workflow

requirements:
  - class: ScatterFeatureRequirement

inputs:
  has_normal: int[]
  output_prefix: string
  java_heap: string
  reference:
    type: File
    secondaryFiles: [.fai, ^.dict]
  common_variant_reference:
    type: File
    secondaryFiles: [.tbi]
  intervals: File
  tumor_bam:
    type: File
    secondaryFiles: [^.bai]
  normal_bam:
    type: File?
    secondaryFiles: [^.bai]

outputs:
  contamination_table:
    type: File
    outputSource: calculate_contamination/contamination_table
  tumor_segments_table:
    type: File
    outputSource: calculate_contamination/tumor_segments_table

steps:
  get_tumor_pileups:
    run: ../../tools/calculate_contamination/get_pileup_summaries.cwl
    in:
      java_heap: java_heap
      reference: reference
      common_variant_reference: common_variant_reference
      intervals: intervals
      bam_file: tumor_bam
    out: [pileups_table]

  get_normal_pileups:
    run: ../../tools/calculate_contamination/get_pileup_summaries.cwl
    scatter: has_normal
    in:
      has_normal: has_normal
      java_heap: java_heap
      reference: reference
      common_variant_reference: common_variant_reference
      intervals: intervals
      bam_file: normal_bam
    out: [pileups_table]

  extract_normal_pileups:
    run: ../../utils-cwl/extract_from_conditional_array.cwl
    in:
      input_array: get_normal_pileups/pileups_table
    out: [input_file]

  calculate_contamination:
    run: ../../tools/calculate_contamination/calculate_contamination.cwl
    in:
      java_heap: java_heap
      tumor_pileups: get_tumor_pileups/pileups_table
      output_prefix: output_prefix
      normal_pileups: extract_normal_pileups/input_file
    out: [contamination_table, tumor_segments_table]
