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
    type: File?
    inputBinding:
      position: 3
      prefix: -I
    secondaryFiles:
      - '^.bai'

  output:
    type: string
    inputBinding:
      position: 4
      prefix: -O

  variant:
    type: File
    doc: common germline variant sites VCF, e.g. derived from the gnomAD resource, with population allele frequencies (AF) in the INFO field.
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

outputs:
  pileup_table:
    type: File
    outputBinding:
      glob: $(inputs.output)

baseCommand: ['java', '-d64', '-XX:+UseSerialGC']
arguments:
  - valueFrom: '/gatk/gatk.jar'
    prefix: '-jar'
    position: 1
  - valueFrom: 'GetPileupSummaries'
    position: 2
