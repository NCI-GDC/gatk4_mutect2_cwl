#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: quay.io/ncigdc/gatk4_multi_mutect2@sha256:17c45f31c71d8f360bc00e738e1f764e7af2a0c8574faf49a53ea1e8b28b6f99

inputs:

  threads:
    type: int
    default: 8
    inputBinding:
      position: 1
      prefix: -c

  java_heap:
    type: string
    default: '3G'
    doc: Java heap memory.
    inputBinding:
      position: 2
      prefix: -j

  tumor_input:
    type: File
    doc: Tumor BAM/SAM/CRAM file containing reads.
    inputBinding:
      position: 3
      prefix: -t
    secondaryFiles:
      - '^.bai'

  reference:
    type: File
    doc: Reference sequence file.
    inputBinding:
      position: 4
      prefix: -f
    secondaryFiles:
      - '.fai'
      - '^.dict'

  tumor_sample:
    type: File
    doc: BAM sample name of tumor from GetSampleName.
    inputBinding:
      loadContents: true
      valueFrom: $(null)

  af_of_alleles_not_in_resource:
    type: float?
    doc: Population allele fraction assigned to alleles not found in germline resource. A reasonable value is1/(2* number of samples in resource) if a germline resource is available; otherwise an average heterozygosity rate such as 0.001 is reasonable.
    inputBinding:
      position: 6
      prefix: -af

  germline_resource:
    type: File?
    doc: Population vcf of germline sequencing containing allele fractions.
    inputBinding:
      position: 7
      prefix: -gr
    secondaryFiles:
     - '.tbi'

  intervals:
    type: File
    doc: One or more genomic intervals over which to operate.
    inputBinding:
      position: 8
      prefix: -r

  panel_of_normals:
    type: File?
    doc: VCF file of sites observed in normal.
    inputBinding:
      position: 9
      prefix: -p
    secondaryFiles:
      - '.tbi'

  dont_use_soft_clipped_bases:
    type: boolean
    doc: Do not analyze soft clipped bases in the reads.
    default: false
    inputBinding:
      position: 10
      prefix: -m

  normal_input:
    type: File?
    doc: Normal BAM/SAM/CRAM file containing reads.
    inputBinding:
      position: 11
      prefix: -n
    secondaryFiles:
      - '^.bai'

  normal_sample:
    type: File?
    doc: BAM sample name of normal from GetSampleName.
    inputBinding:
      loadContents: true
      valueFrom: $(null)

outputs:
  output_vcf:
    type: File
    outputBinding:
      glob: 'merged_multi_gatk4_mutect2_calling.vcf'

baseCommand: ['python', '/bin/multi_gatk4_mutect2.py']
arguments:
  - valueFrom: $(inputs.tumor_sample.contents.replace(/\n/g, ''))
    prefix: -ts
    position: 5
  - valueFrom: |
      ${
        var n_sample = "";
        if( inputs.normal_sample ) {
          n_sample = inputs.normal_sample.contents.replace(/\n/g, '')
        } else {
          n_sample = null
        };
        return n_sample
      }
    prefix: -ns
    position: 12
