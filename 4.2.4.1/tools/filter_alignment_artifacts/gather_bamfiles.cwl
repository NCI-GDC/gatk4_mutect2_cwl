#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/gatk4_multi_mutect2:4.2.4.1

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
