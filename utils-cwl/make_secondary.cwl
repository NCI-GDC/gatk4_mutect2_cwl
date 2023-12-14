#!/usr/bin/env cwl-runner

id: make_secondary
cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: DockerRequirement
    dockerPull: "{{ docker_repo }}/bio-alpine:{{ bio_alpine }}"
  - class: InlineJavascriptRequirement
  - class: InitialWorkDirRequirement
    listing:
      - $(inputs.parent_file)
      - $(inputs.children)

inputs:
  parent_file:
    type: File

  children:
    type: File[]

outputs:
  output:
    type: File
    outputBinding:
      glob: $(inputs.parent_file.basename)
    secondaryFiles: $(inputs.children)

baseCommand: "true"
