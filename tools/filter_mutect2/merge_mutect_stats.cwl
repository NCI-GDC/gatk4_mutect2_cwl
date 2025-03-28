#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: "{{ docker_repo }}/ncigdc/gatk4-mutect2-tool:{{ gatk4-mutect2-tool }}"

inputs:
  java_heap: string
  output_prefix: string
  stats:
    type:
      type: array
      items: File
      inputBinding:
        prefix: -stats
    inputBinding:
      position: 99

outputs:
  mutect2_stats:
    type: File
    outputBinding:
      glob: $(inputs.output_prefix + '.mutect2.merged.stats')

baseCommand: []
arguments:
    - position: 0
      shellQuote: false
      valueFrom: >-
        /usr/local/bin/gatk --java-options "-XX:+UseSerialGC -Xmx$(inputs.java_heap)" MergeMutectStats \
        -O $(inputs.output_prefix).mutect2.merged.stats
