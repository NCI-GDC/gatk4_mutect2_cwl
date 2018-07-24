
#!/usr/bin/env cwl-runner

cwlVersion: v1.0

requirements:
  - class: InlineJavascriptRequirement

class: ExpressionTool

inputs:
  input_array: File[]

outputs:
  input_file: File

expression: |
  ${
    if (inputs.input_array.length == 1) {
      var input_file = inputs.input_array[0];
    } else if (inputs.input_array.length == 0) {
      var input_file = null;
    }
    return {'input_file': input_file}
  }
