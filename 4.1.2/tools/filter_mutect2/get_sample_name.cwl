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
  reference:
    type: File
    secondaryFiles: [.fai, ^.dict]
  normal_bam:
    type: File
    secondaryFiles: [^.bai]

outputs:
  normal_sample:
    type: string
    outputBinding:
      glob: 'normal_name.txt'
      loadContents: true
      outputEval: $(self[0].contents.trim())

baseCommand: []
arguments:
    - position: 0
      shellQuote: false
      valueFrom: >-
        /opt/gatk-4.1.2.0/gatk --java-options "-XX:+UseSerialGC -Xmx$(inputs.java_heap)" GetSampleName \
        -R $(inputs.reference.path) -I $(inputs.normal_bam.path) -O normal_name.txt -encode