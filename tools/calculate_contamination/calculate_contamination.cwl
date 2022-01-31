#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/gatk4-mutect2-tool:0.1.0-20-g6b2c31c

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
        /usr/local/bin/gatk --java-options "-XX:+UseSerialGC -Xmx$(inputs.java_heap)" CalculateContamination \
        -I $(inputs.tumor_pileups.path) -O $(inputs.output_prefix).contamination.table --tumor-segmentation $(inputs.output_prefix).segments.table
