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

  input:
    type: File[]
    doc: BAM/SAM/CRAM file containing reads.
    inputBinding:
      position: 3
      prefix: -I
    secondaryFiles:
      - '^.bai'

  output:
    type: string
    doc: To which variants should be written.
    inputBinding:
      position: 4
      prefix: -O

  reference:
    type: File
    doc: Reference sequence file.
    inputBinding:
      position: 5
      prefix: -R
    secondaryFiles:
      - '.fai'
      - '^.dict'

  tumor_sample:
    type: string
    doc: BAM sample name of tumor. May be URL-encoded as output by GetSampleName with -encode argument.
    inputBinding:
      position: 6
      prefix: -tumor

  af_of_alleles_not_in_resource:
    type: float?
    doc: Population allele fraction assigned to alleles not found in germline resource. A reasonable value is1/(2* number of samples in resource) if a germline resource is available; otherwise an average heterozygosity rate such as 0.001 is reasonable.
    inputBinding:
      position: 7
      prefix: --af-of-alleles-not-in-resource

  contamination_fraction_to_filter:
    type: double
    doc: Fraction of contamination in sequencing data (for all samples) to aggressively remove.
    default: 0.0
    inputBinding:
      position: 8
      prefix: -contamination

  germline_resource:
    type: File?
    doc: Population vcf of germline sequencing containing allele fractions.
    inputBinding:
      position: 9
      prefix: --germline-resource
    secondaryFiles:
     - '.tbi'

  intervals:
    type: string[]?
    doc: One or more genomic intervals over which to operate.
    inputBinding:
      position: 10
      prefix: -L

  normal_sample:
    type: string?
    doc: BAM sample name of normal. May be URL-encoded as output by GetSampleName with -encode argument.
    inputBinding:
      position: 11
      prefix: -normal

  panel_of_normals:
    type: File?
    doc: VCF file of sites observed in normal.
    inputBinding:
      position: 12
      prefix: -pon
    secondaryFiles:
      - '.tbi'

  dont_use_soft_clipped_bases:
    type: boolean
    doc: Do not analyze soft clipped bases in the reads.
    default: false
    inputBinding:
      position: 13
      prefix: --dont-use-soft-clipped-bases

outputs:
  output_vcf:
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
  - valueFrom: 'Mutect2'
    position: 2
