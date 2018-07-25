#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: ScatterFeatureRequirement
  - class: StepInputExpressionRequirement

inputs:
  java_heap: string
  tumor_with_index:
    type: File
    secondaryFiles:
      - '^.bai'
  output_prefix: string
  reference_with_index:
    type: File
    secondaryFiles:
      - '.fai'
      - '^.dict'
  common_biallelic_variants_with_index:
    type: File
    secondaryFiles:
      - '.tbi'
  input_bed: File
  sorted_vcf:
    type: File
    secondaryFiles:
      - '.tbi'
  normal_with_index:
    type: File?
    secondaryFiles:
      - '^.bai'
  artifact_modes:
    type: string[]
    default: ["G/T", "C/T"]
  has_normal: int[]

outputs:
  contFiltered_oxogFiltered_vcf:
    type: File
    outputSource: filterbyorientationbias/oxog_filtered_vcf

steps:
  get_oxog_metrics:
    run: ../../tools/gatk4_collectsequencingartifactmetrics.cwl
    in:
      java_heap: java_heap
      input: tumor_with_index
      output: output_prefix
      reference: reference_with_index
    out: [metrics]

  getpileupsummaries_on_tumor:
    run: ../../tools/gatk4_getpileupsummaries.cwl
    in:
      java_heap: java_heap
      input: tumor_with_index
      output:
        source: output_prefix
        valueFrom: $(self + '.tumor.table')
      variant: common_biallelic_variants_with_index
      intervals: input_bed
      reference: reference_with_index
    out: [pileup_table]

  getpileupsummaries_on_normal:
    run: ../../tools/gatk4_getpileupsummaries.cwl
    scatter: has_normal
    in:
      has_normal: has_normal
      java_heap: java_heap
      input: normal_with_index
      output:
        source: output_prefix
        valueFrom: $(self + '.normal.table')
      variant: common_biallelic_variants_with_index
      intervals: input_bed
      reference: reference_with_index
    out: [pileup_table]

  extract_normal_pileup_table:
    run: ../extract_from_conditional_array.cwl
    in:
      input_array: getpileupsummaries_on_normal/pileup_table
    out: [input_file]

  calculatecontamination:
    run: ../../tools/gatk4_calculatecontamination.cwl
    in:
      java_heap: java_heap
      input: getpileupsummaries_on_tumor/pileup_table
      matched_normal: extract_normal_pileup_table/input_file
      output:
        source: output_prefix
        valueFrom: $(self + '.contamination.table')
    out: [contamination_table]

  filtermutectcalls:
    run: ../../tools/gatk4_filtermutectcalls.cwl
    in:
      java_heap: java_heap
      output:
        source: output_prefix
        valueFrom: $(self + '.contFiltered.vcf.gz')
      variant: sorted_vcf
      contamination_table: calculatecontamination/contamination_table
      intervals: input_bed
    out: [filtered_vcf]

  filterbyorientationbias:
    run: ../../tools/gatk4_filterbyorientationbias.cwl
    in:
      java_heap: java_heap
      output:
        source: output_prefix
        valueFrom: $(self + '.gatk4_mutect2.raw_somatic_mutation.vcf.gz')
      pre_adapter_detail_file: get_oxog_metrics/metrics
      variant: filtermutectcalls/filtered_vcf
      intervals: input_bed
      reference: reference_with_index
      artifact_modes: artifact_modes
    out: [oxog_filtered_vcf]
