#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: "{{ docker_repo }}/ncigdc/gatk4-mutect2-tool:{{ gatk4-mutect2-tool }}"

inputs:
  tumor_bam:
    type: File
    secondaryFiles: [^.bai]
    inputBinding:
      prefix: --tumor_bam
      position: 0
  vcf:
    type: File
    secondaryFiles: [.tbi]
    inputBinding:
      prefix: --vcf
      position: 1
  output_prefix:
    type: string
    inputBinding:
      prefix: --output
      position: 2
      valueFrom: $(self).gatk4_mutect2.raw_somatic_mutation.vcf.gz
  normal_bam:
    type: File?
    secondaryFiles: [^.bai]
    inputBinding:
      prefix: --normal_bam
      position: 99

outputs:
  gdc_gatk4_mutect2_vcf:
    type: File
    secondaryFiles: [.tbi]
    outputBinding:
      glob: $(inputs.output_prefix + '.gatk4_mutect2.raw_somatic_mutation.vcf.gz')

baseCommand: ['modify_vcf_sample']
