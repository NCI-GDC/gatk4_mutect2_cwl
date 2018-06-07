#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: InlineJavascriptRequirement

class: ExpressionTool

inputs:
  project_id:
    type: string?

  job_id:
    type: string

  experimental_strategy:
    type: string?

outputs:
  output_prefix:
    type: string

expression: |
  ${
     var exp = inputs.experimental_strategy ? '.' + inputs.experimental_strategy.toLowerCase().replace(/[-\s]/g, "_"): '';
     var pid = inputs.project_id ? inputs.project_id + '.': '';
     var pfx = pid + inputs.job_id + exp;
     return {'output_prefix': pfx};
   }
