#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/gatk4_multi_mutect2:4.2.4.1
  - class: InitialWorkDirRequirement
    listing:
      - entry: $(inputs.input_bam_path)
        entryname: $(inputs.input_bam_path.basename)

inputs:
  java_heap: string
  input_bam_path: File

outputs:
  sorted_bam_with_index:
    type: File
    outputBinding:
      glob: $(inputs.input_bam_path.basename)
    secondaryFiles: [^.bai]

baseCommand: []
arguments:
    - position: 0
      shellQuote: false
      valueFrom: >-
        /usr/local/bin/gatk --java-options "-XX:+UseSerialGC -Xmx$(inputs.java_heap)" BuildBamIndex \
        -I $(inputs.input_bam_path.path) -VALIDATION_STRINGENCY LENIENT
