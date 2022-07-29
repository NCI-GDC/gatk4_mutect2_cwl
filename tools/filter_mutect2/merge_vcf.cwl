#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/gatk:4.2.4.1

inputs:
  java_heap: string
  output_prefix: string
  vcfs:
    type:
      type: array
      items: File
      inputBinding:
        prefix: -I
    inputBinding:
      position: 99

outputs:
  mutect2_unfiltered_vcf:
    type: File
    outputBinding:
      glob: $(inputs.output_prefix + '.mutect2.vcf.gz')
    secondaryFiles: [.tbi]

baseCommand: []
arguments:
    - position: 0
      shellQuote: false
      valueFrom: >-
        /usr/local/bin/gatk --java-options "-XX:+UseSerialGC -Xmx$(inputs.java_heap)" MergeVcfs \
        -O $(inputs.output_prefix).mutect2.vcf.gz
