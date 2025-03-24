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
  reference:
    type: File
    secondaryFiles: [.fai, ^.dict]
  common_variant_reference:
    type: File
    secondaryFiles: [.tbi]
  intervals: File
  bam_file:
    type: File?
    secondaryFiles: [^.bai]

outputs:
  pileups_table:
    type: File
    outputBinding:
      glob: $(inputs.bam_file.nameroot + '.pileups.table')

baseCommand: []
arguments:
    - position: 0
      shellQuote: false
      valueFrom: >-
        /usr/local/bin/gatk --java-options "-XX:+UseSerialGC -Xmx$(inputs.java_heap)" GetPileupSummaries -R $(inputs.reference.path) \
        -I $(inputs.bam_file.path) -V $(inputs.common_variant_reference.path) -L $(inputs.intervals.path) -O $(inputs.bam_file.nameroot).pileups.table
