#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement

inputs:
  java_heap: string
  input:
    type: File
    secondaryFiles:
      - '^.bai'
  output: string
  file_extension: string
  reference:
    type: File
    secondaryFiles:
      - '.fai'
      - '^.dict'

outputs:
  sample_name:
    type: File
    outputSource: get_tumor_sample_name/samplename
  oxog_metrics:
    type: File
    outputSource: get_oxog_metrics/metrics

steps:
  get_tumor_sample_name:
    run: ../tools/gatk4_getsamplename.cwl
    in:
      java_heap: java_heap
      input: input
      output: output
    out: [samplename]

  get_oxog_metrics:
    run: ../tools/gatk4_collectsequencingartifactmetrics.cwl
    in:
      java_heap: java_heap
      input: input
      output: output
      file_extension: file_extension
      reference: reference
    out: [metrics]
