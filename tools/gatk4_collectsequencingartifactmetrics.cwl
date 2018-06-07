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
    secondaryFiles:
      - '^.bai'

  output:
    type: string
    inputBinding:
      position: 4
      prefix: -O

  file_extension:
    type: string
    default: '.txt'
    inputBinding:
      position: 5
      prefix: --FILE_EXTENSION

  reference:
    type: File
    inputBinding:
      position: 6
      prefix: -R
    secondaryFiles:
      - '.fai'
      - '^.dict'

outputs:
  metrics:
    type: File
    outputBinding:
      glob: $(inputs.output + '.pre_adapter_detail_metrics' + inputs.file_extension)

baseCommand: ['java', '-d64', '-XX:+UseSerialGC']
arguments:
  - valueFrom: '/gatk/gatk.jar'
    prefix: '-jar'
    position: 1
  - valueFrom: 'CollectSequencingArtifactMetrics'
    position: 2
