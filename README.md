# GATK4 MuTect2 CWL

This is a GitHub repository for the GATK4 MuTect2 Common Workflow Language (CWL). The MuTect2 tool is a highly sensitive somatic variant caller that can detect somatic mutations in tumor-normal sample pairs.

## Installation

To use this CWL tool, you'll need to have Docker and CWLtool installed on your system. You can download and install these tools from their respective websites.

Once you have Docker and CWLtool installed, you can download the MuTect2 CWL tool by cloning this GitHub repository:

```
git clone https://github.com/NCI-GDC/gatk4_mutect2_cwl.git
```

## Usage

To run the MuTect2 CWL tool, you'll need to provide it with input files, such as BAM files for the tumor and normal samples, and reference files for the genome and for filtration/annotation. You can find more information about the input files and their formats in the `/example`.

To run the tool, you can use the following command:

```
cwltool gatk4_mutect2.cwl inputs.yaml
```

This will launch the CWL tool and run the MuTect2 workflow. The output files will be written to the `./output` directory.


## License

This MuTect2 CWL tool is released under the Apache 2.0 license. See the LICENSE file for more information.
