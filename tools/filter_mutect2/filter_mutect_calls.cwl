#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/gatk4-mutect2-tool:0.2.1-20-gb81bfd1
  - class: ResourceRequirement
    coresMin: 1
    coresMax: 1
    ramMin: 4000
    ramMax: 8000

inputs:
  java_heap: string
  unfiltered_vcf:
    type: File
    secondaryFiles: [.tbi]
  reference:
    type: File
    secondaryFiles: [.fai, ^.dict]
  output_prefix: string
  contamination_table: File
  tumor_segments_table: File
  artifacts_priors: File
  mutect2_stats: File

outputs:
  filtered_vcf:
    type: File
    outputBinding:
      glob: $(inputs.output_prefix + '.gatk4_mutect2.filtered.vcf.gz')
    secondaryFiles: [.tbi]

baseCommand: []
arguments:
    - position: 0
      shellQuote: false
      valueFrom: >-
        /usr/local/bin/gatk --java-options "-XX:+UseSerialGC -Xmx$(inputs.java_heap)" FilterMutectCalls \
        -V $(inputs.unfiltered_vcf.path) -R $(inputs.reference.path) -O $(inputs.output_prefix).gatk4_mutect2.filtered.vcf.gz \
        --contamination-table $(inputs.contamination_table.path) --tumor-segmentation $(inputs.tumor_segments_table.path) --ob-priors $(inputs.artifacts_priors.path) \
        -stats $(inputs.mutect2_stats.path) --filtering-stats filtering.stats
