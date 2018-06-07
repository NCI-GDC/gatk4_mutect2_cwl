#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: broadinstitute/gatk:4.0.4.0
  - class: ResourceRequirement
    coresMax: 1

inputs:
  java_heap:
    type: string
    default: '3G'
    doc: Java heap memory.
    inputBinding:
      position: 0
      prefix: '-Xmx'
      separate: false

  output:
    type: string
    inputBinding:
      position: 3
      prefix: -O

  pre_adapter_detail_file:
    type: File
    inputBinding:
      position: 4
      prefix: -P

  variant:
    type: File
    inputBinding:
      position: 5
      prefix: -V
    secondaryFiles:
      - '.tbi'

  intervals:
    type: File?
    doc: One or more genomic intervals over which to operate.
    inputBinding:
      position: 6
      prefix: -L

  reference:
    type: File?
    inputBinding:
      position: 7
      prefix: -R
    secondaryFiles:
      - '.fai'
      - '^.dict'

  artifact_modes:
    type:
      type: array
      items: string
      inputBinding:
        prefix: -AM
    inputBinding:
      position: 8

outputs:
  oxog_filtered_vcf:
    type: File
    outputBinding:
      glob: $(inputs.output)
    secondaryFiles:
      - '.tbi'

baseCommand: ['java', '-d64', '-XX:+UseSerialGC']
arguments:
  - valueFrom: '/gatk/gatk.jar'
    prefix: '-jar'
    position: 1
  - valueFrom: 'FilterByOrientationBias'
    position: 2
