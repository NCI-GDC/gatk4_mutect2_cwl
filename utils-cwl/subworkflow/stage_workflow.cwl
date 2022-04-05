#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement
  - class: ScatterFeatureRequirement

class: Workflow

inputs:
  pon_calling: int[]
  has_normal: int[]
  tumor: File
  tumor_index: File
  normal: File?
  normal_index: File?
  reference: File
  reference_fai: File
  reference_dict: File
  germline_ref: File?
  germline_ref_index: File?
  biallelic_ref: File?
  biallelic_ref_index: File?
  pon: File?
  pon_index: File?

outputs:
  tumor_with_index:
    type: File
    outputSource: make_tumor_bam/output
  reference_with_index:
    type: File
    outputSource: make_reference/output
  normal_with_index:
    type: File?
    outputSource: extract_normal/input_file
  pon_with_index:
    type: File?
    outputSource: extract_pon/input_file
  biallelic_ref_with_index:
    type: File?
    outputSource: extract_biallelic_ref/input_file
  germline_ref_with_index:
    type: File?
    outputSource: extract_germline_ref/input_file

steps:
  standardize_tumor_bai:
    run: ../rename_file.cwl
    in:
      input_file: tumor_index
      output_filename:
        source: tumor_index
        valueFrom: |
          ${
             return self.basename.lastIndexOf('.bam') !== -1 ?
                    self.basename.substr(0, self.basename.lastIndexOf('.bam')) + '.bai' :
                    self.basename
           }
    out: [ out_file ]

  make_tumor_bam:
    run: ../make_secondary.cwl
    in:
      parent_file: tumor
      children:
        source: standardize_tumor_bai/out_file
        valueFrom: $([self])
    out: [ output ]

  standardize_normal_bai:
    run: ../rename_file.cwl
    scatter: has_normal
    in:
      has_normal: has_normal
      input_file: normal_index
      output_filename:
        source: normal_index
        valueFrom: |
          ${
             return self.basename.lastIndexOf('.bam') !== -1 ?
                    self.basename.substr(0, self.basename.lastIndexOf('.bam')) + '.bai' :
                    self.basename
           }
    out: [ out_file ]

  make_normal_bam:
    run: ../make_secondary.cwl
    scatter: has_normal
    in:
      has_normal: has_normal
      parent_file: normal
      children: standardize_normal_bai/out_file
    out: [ output ]

  extract_normal:
    run: ../extract_from_conditional_array.cwl
    in:
      input_array: make_normal_bam/output
    out: [input_file]

  make_reference:
    run: ../make_secondary.cwl
    in:
      parent_file: reference
      children:
        source: [reference_fai, reference_dict]
        valueFrom: $(self)
    out: [ output ]

  make_pon:
    run: ../make_secondary.cwl
    scatter: pon_calling
    in:
      pon_calling: pon_calling
      parent_file: pon
      children:
        source: pon_index
        valueFrom: $([self])
    out: [ output ]

  extract_pon:
    run: ../extract_from_conditional_array.cwl
    in:
      input_array: make_pon/output
    out: [input_file]

  make_biallelic_ref:
    run: ../make_secondary.cwl
    scatter: pon_calling
    in:
      pon_calling: pon_calling
      parent_file: biallelic_ref
      children:
        source: biallelic_ref_index
        valueFrom: $([self])
    out: [ output ]

  extract_biallelic_ref:
    run: ../extract_from_conditional_array.cwl
    in:
      input_array: make_biallelic_ref/output
    out: [input_file]

  make_germline_ref:
    run: ../make_secondary.cwl
    scatter: pon_calling
    in:
      pon_calling: pon_calling
      parent_file: germline_ref
      children:
        source: germline_ref_index
        valueFrom: $([self])
    out: [ output ]

  extract_germline_ref:
    run: ../extract_from_conditional_array.cwl
    in:
      input_array: make_germline_ref/output
    out: [input_file]