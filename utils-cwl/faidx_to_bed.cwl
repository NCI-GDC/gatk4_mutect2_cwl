#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: DockerRequirement
    dockerPull: alpine
  - class: InlineJavascriptRequirement
  - class: ShellCommandRequirement

inputs:
  ref_fai:
    type: File
    doc: Reference faidx path. (i.e. GRCh38.d1.vd1.fa.fai)

  usedecoy:
    type: boolean
    doc: If specified, it will include all the decoy sequences in the faidx.

outputs:
  output_bed:
    type: File
    outputBinding:
      glob: 'intervals.bed'

stdout: 'intervals.bed'

baseCommand: []

arguments:
  - valueFrom: |
      ${
         var cmd = ['cat', inputs.ref_fai.path, '|', 'awk']
         if( inputs.usedecoy ) {
             cmd.push("\'{print $1 \"\\t0\\t\" $2}\'")
         } else {
             cmd.push("\'{if($0~/^chr[1-9MXY]+[[:space:]]/){print $1 \"\\t0\\t\" $2}}\'")
         }
         return(cmd.join(' '))
       }
    shellQuote: false
