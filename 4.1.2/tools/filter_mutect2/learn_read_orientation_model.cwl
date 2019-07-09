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
  output_prefix: string
  f1r2s:
    type:
      type: array
      items: File
      inputBinding:
        prefix: -I
    inputBinding:
      position: 99

outputs:
  artifacts_priors:
    type: File
    outputBinding:
      glob: $(inputs.output_prefix + '.artifacts_priors.tar.gz')

baseCommand: []
arguments:
    - position: 0
      shellQuote: false
      valueFrom: >-
        /opt/gatk-4.1.2.0/gatk --java-options "-XX:+UseSerialGC -Xmx$(inputs.java_heap)" LearnReadOrientationModel \
        -O $(inputs.output_prefix).artifacts_priors.tar.gz
