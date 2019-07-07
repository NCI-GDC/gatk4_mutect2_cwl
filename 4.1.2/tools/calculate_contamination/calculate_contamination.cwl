#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/gatk4_multi_mutect2:4.1.2

inputs:
  java_heap: string
  tumor_pileups: File
  output_prefix: string
  normal_pileups:
    type: File?
    inputBinding:
      prefix: -matched
      position: 99
      shellQuote: false

outputs:
  contamination_table:
    type: File
    outputBinding:
      glob: $(inputs.output_prefix + '.contamination.table')
  tumor_segments_table:
    type: File
    outputBinding:
      glob: $(inputs.output_prefix + '.segments.table')

baseCommand: []
arguments:
    - position: 0
      shellQuote: false
      valueFrom: >-
        /opt/gatk-4.1.2.0/gatk --java-options "-XX:+UseSerialGC -Xmx$(inputs.java_heap)" CalculateContamination \
        -I $(inputs.tumor_pileups.path) -O $(inputs.output_prefix).contamination.table --tumor-segmentation $(inputs.output_prefix).segments.table