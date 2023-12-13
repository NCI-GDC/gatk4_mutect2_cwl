#!/usr/bin/env cwl-runner

cwlVersion: v1.2

requirements:
  - class: DockerRequirement
    dockerImageId: "alpine"
  - class: InlineJavascriptRequirement
    dockerRequirement:
      class: DockerRequirement
      dockerImageId: "alpine"
  - class: InitialWorkDirRequirement
    listing: |
      ${
           var ret = [{"entryname": inputs.parent_file.basename, "entry": inputs.parent_file}];
           for( var i = 0; i < inputs.children.length; i++ ) {
               ret.push({"entryname": inputs.children[i].basename, "entry": inputs.children[i]});
           };
           return ret
       }

class: CommandLineTool

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
    secondaryFiles: |
      ${
         var ret = [];
         var locbase = inputs.parent_file.location.substr(0, inputs.parent_file.location.lastIndexOf('/'))
         for( var i = 0; i < inputs.children.length; i++ ) {
           ret.push({"class": "File", "location": locbase + '/' + inputs.children[i].basename});
         }
         return ret
       }

baseCommand: "true"
