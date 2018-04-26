#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement

inputs:
  java_heap: string
  tumor_bam:
    type: File
    secondaryFiles:
      - '^.bai'
  tumor_barcode: string
  output_prefix: string
  reference:
    type: File
    secondaryFiles:
      - '.fai'
      - '^.dict'
  af_of_alleles_not_in_resource: float
  germline_resource:
    type: File
    secondaryFiles:
      - '.tbi'
  intervals: string[]?
  panel_of_normals:
    type: File
    secondaryFiles:
      - '.tbi'
  dont_use_soft_clipped_bases: boolean
  common_biallelic_variants:
    type: File
    secondaryFiles:
      - '.tbi'
  metrics: File
  artifact_modes: string[]

outputs:

  FILTERED_MUTECT2_VCF:
    type: File
    outputSource: filterbyorientationbias/oxog_filtered_vcf

steps:

  mutect2_call:
    run: ../tools/gatk4_mutect2.cwl
    in:
      java_heap: java_heap
      input: tumor_bam
      output:
        source: output_prefix
        valueFrom: $(self + '.mutect2.raw.vcf.gz')
      reference: reference
      tumor_sample: tumor_barcode
      af_of_alleles_not_in_resource: af_of_alleles_not_in_resource
      germline_resource: germline_resource
      intervals: intervals
      panel_of_normals: panel_of_normals
      dont_use_soft_clipped_bases: dont_use_soft_clipped_bases
    out: [output_vcf]

  getpileupsummaries_on_tumor:
    run: ../tools/gatk4_getpileupsummaries.cwl
    in:
      java_heap: java_heap
      input: tumor_bam
      output:
        source: output_prefix
        valueFrom: $(self + '.table')
      variant: common_biallelic_variants
      intervals: intervals
      reference: reference
    out: [pileup_table]

  calculatecontamination_on_tumor:
    run: ../tools/gatk4_calculatecontamination.cwl
    in:
      java_heap: java_heap
      input: getpileupsummaries_on_tumor/pileup_table
      output:
        source: output_prefix
        valueFrom: $(self + '.contamination.table')
    out: [contamination_table]

  filtermutectcalls:
    run: ../tools/gatk4_filtermutectcalls.cwl
    in:
      java_heap: java_heap
      output:
        source: output_prefix
        valueFrom: $(self + '.mutect2.contFiltered.vcf.gz')
      variant: mutect2_call/output_vcf
      contamination_table: calculatecontamination_on_tumor/contamination_table
      intervals: intervals
    out: [filtered_vcf]

  filterbyorientationbias:
    run: ../tools/gatk4_filterbyorientationbias.cwl
    in:
      java_heap: java_heap
      output:
        source: output_prefix
        valueFrom: $(self + '.mutect2.contFiltered.oxogFiltered.vcf.gz')
      pre_adapter_detail_file: metrics
      variant: filtermutectcalls/filtered_vcf
      intervals: intervals
      reference: reference
      artifact_modes: artifact_modes
    out: [oxog_filtered_vcf]
