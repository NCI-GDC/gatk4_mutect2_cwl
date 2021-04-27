#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/modify_vcf_sample:1.0

inputs:
  tumor_bam:
    type: File
    secondaryFiles: [^.bai]
  normal_bam:
    type: File?
    secondaryFiles: [^.bai]
    inputBinding:
      prefix: --normal_bam
      position: 99
  vcf:
    type: File
    secondaryFiles: [.tbi]
  output_prefix: string

outputs:
  gdc_gatk4_mutect2_vcf:
    type: File
    secondaryFiles: [.tbi]
    outputBinding:
      glob: $(inputs.output_prefix + '.gatk4_mutect2.raw_somatic_mutation.vcf.gz')

baseCommand: []
arguments:
    - position: 0
      shellQuote: false
      valueFrom: >-
        python /opt/modify_vcf_sample.py --tumor_bam $(inputs.tumor_bam.path) --vcf $(inputs.vcf.path) --output $(inputs.output_prefix).gatk4_mutect2.raw_somatic_mutation.vcf.gz
