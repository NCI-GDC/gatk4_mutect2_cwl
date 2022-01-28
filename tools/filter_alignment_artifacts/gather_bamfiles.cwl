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
  output_prefix: string
  reference:
    type: File
    secondaryFiles: [.fai, ^.dict]
  bam_outs:
    type:
      type: array
      items: File
      inputBinding:
        prefix: -I
    inputBinding:
      position: 99

outputs:
  merged_out_bam:
    type: File
    outputBinding:
      glob: $(inputs.output_prefix + '.unsorted.out.bam')

baseCommand: []
arguments:
    - position: 0
      shellQuote: false
      valueFrom: >-
        /usr/local/bin/gatk --java-options "-XX:+UseSerialGC -Xmx$(inputs.java_heap)" GatherBamFiles \
        -O $(inputs.output_prefix).unsorted.out.bam -R $(inputs.reference.path)
