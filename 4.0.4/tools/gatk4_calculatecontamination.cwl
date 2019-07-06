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

  input:
    type: File
    inputBinding:
      position: 3
      prefix: -I

  output:
    type: string
    inputBinding:
      position: 4
      prefix: -O

  matched_normal:
    type: File?
    inputBinding:
      position: 5
      prefix: -matched

outputs:
  contamination_table:
    type: File
    outputBinding:
      glob: $(inputs.output)

baseCommand: ['java', '-d64', '-XX:+UseSerialGC']
arguments:
  - valueFrom: '/gatk/gatk.jar'
    prefix: '-jar'
    position: 1
  - valueFrom: 'CalculateContamination'
    position: 2