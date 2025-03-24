#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: {{ docker_repo }}/gatk4-mutect2-tool:{{ gatk4-mutect2-tool }}

inputs:
  java_heap: string
  unsorted_bam: File
  output_prefix: string

outputs:
  sorted_out_bam:
    type: File
    outputBinding:
      glob: $(inputs.output_prefix + '.srt.out.bam')

baseCommand: []
arguments:
    - position: 0
      shellQuote: false
      valueFrom: >-
        /usr/local/bin/gatk --java-options "-XX:+UseSerialGC -Xmx$(inputs.java_heap)" SortSam \
        -I $(inputs.unsorted_bam.path) -O $(inputs.output_prefix).srt.out.bam --SORT_ORDER coordinate -VALIDATION_STRINGENCY LENIENT
