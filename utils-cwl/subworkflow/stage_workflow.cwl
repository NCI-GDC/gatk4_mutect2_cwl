#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement

class: Workflow

inputs:
  tumor: File
  tumor_index: File
  reference: File
  reference_fai: File
  reference_dict: File
  germline_ref: File
  germline_ref_index: File
  biallelic_ref: File
  biallelic_ref_index: File
  pon: File
  pon_index: File

outputs:
  tumor_with_index:
    type: File
    outputSource: make_tumor_bam/output
  reference_with_index:
    type: File
    outputSource: make_reference/output
  pon_with_index:
    type: File
    outputSource: make_pon/output
  biallelic_ref_with_index:
    type: File
    outputSource: make_biallelic_ref/output
  germline_ref_with_index:
    type: File
    outputSource: make_germline_ref/output

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
    in:
      parent_file: pon
      children:
        source: pon_index
        valueFrom: $([self])
    out: [ output ]

  make_biallelic_ref:
    run: ../make_secondary.cwl
    in:
      parent_file: biallelic_ref
      children:
        source: biallelic_ref_index
        valueFrom: $([self])
    out: [ output ]

  make_germline_ref:
    run: ../make_secondary.cwl
    in:
      parent_file: germline_ref
      children:
        source: germline_ref_index
        valueFrom: $([self])
    out: [ output ]
