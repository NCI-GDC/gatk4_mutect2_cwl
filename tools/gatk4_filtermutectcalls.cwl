#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: broadinstitute/gatk:4.0.3.0
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

  variant:
    type: File
    inputBinding:
      position: 4
      prefix: -V
    secondaryFiles:
      - '.tbi'

  contamination_table:
    type: File
    inputBinding:
      position: 5
      prefix: --contamination-table

  intervals:
    type: string[]?
    inputBinding:
      position: 6
      prefix: -L

outputs:
  filtered_vcf:
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
  - valueFrom: 'FilterMutectCalls'
    position: 2
