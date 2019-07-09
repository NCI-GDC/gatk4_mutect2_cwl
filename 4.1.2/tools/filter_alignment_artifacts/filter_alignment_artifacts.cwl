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
  input_vcf:
    type: File
    secondaryFiles: [.tbi]
  reassembly_bam:
    type: File
    secondaryFiles: [^.bai]
  reference_image: File
  output_prefix: string
  call_on_all:
    type: boolean
    inputBinding:
      prefix: --dont-skip-filtered-variants
      position: 99
      shellQuote: false

outputs:
  alignment_artifacts_filtered_vcf:
    type: File
    outputBinding:
      glob: $(inputs.output_prefix + '.gatk4_mutect2.raw_somatic_mutation.vcf.gz')
    secondaryFiles: [.tbi]

baseCommand: []
arguments:
    - position: 0
      shellQuote: false
      valueFrom: >-
        /opt/gatk-4.1.2.0/gatk --java-options "-XX:+UseSerialGC -Xmx$(inputs.java_heap)" FilterAlignmentArtifacts \
        -V $(inputs.input_vcf.path) -I $(inputs.reassembly_bam.path) --bwa-mem-index-image $(inputs.reference_image.path) -O $(inputs.output_prefix).gatk4_mutect2.raw_somatic_mutation.vcf.gz
