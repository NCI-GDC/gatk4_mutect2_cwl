#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

requirements:
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement

inputs:
  bioclient_config:
    type: File
  tumor_gdc_id:
    type: string
  tumor_index_gdc_id:
    type: string
  reference_dict_gdc_id:
    type: string
  reference_fa_gdc_id:
    type: string
  reference_fai_gdc_id:
    type: string
  germline_resource_gdc_id:
    type: string
  germline_resource_index_gdc_id:
    type: string
  common_biallelic_variants_gdc_id:
    type: string
  common_biallelic_variants_index_gdc_id:
    type: string
  panel_of_normal_gdc_id:
    type: string
  panel_of_normal_index_gdc_id:
    type: string

outputs:
  tumor_with_index:
    type: File
    outputSource: stage/tumor_with_index
  reference_with_index:
    type: File
    outputSource: stage/reference_with_index
  germline_resource_with_index:
    type: File
    outputSource: stage/germline_ref_with_index
  common_biallelic_variants_with_index:
    type: File
    outputSource: stage/biallelic_ref_with_index
  panel_of_normal_with_index:
    type: File
    outputSource: stage/pon_with_index

steps:
  tumor_download:
    run: ../bioclient/tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: tumor_gdc_id
    out: [output]

  tumor_index_download:
    run: ../bioclient/tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: tumor_index_gdc_id
    out: [output]

  reference_dict_download:
    run: ../bioclient/tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: reference_dict_gdc_id
    out: [output]

  reference_fa_download:
    run: ../bioclient/tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: reference_fa_gdc_id
    out: [output]

  reference_fai_download:
    run: ../bioclient/tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: reference_fai_gdc_id
    out: [output]

  germline_resource_download:
    run: ../bioclient/tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: germline_resource_gdc_id
    out: [output]

  germline_resource_index_download:
    run: ../bioclient/tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: germline_resource_index_gdc_id
    out: [output]

  common_biallelic_variants_download:
    run: ../bioclient/tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: common_biallelic_variants_gdc_id
    out: [output]

  common_biallelic_variants_index_download:
    run: ../bioclient/tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: common_biallelic_variants_index_gdc_id
    out: [output]

  panel_of_normal_download:
    run: ../bioclient/tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: panel_of_normal_gdc_id
    out: [output]

  panel_of_normal_index_download:
    run: ../bioclient/tools/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: panel_of_normal_index_gdc_id
    out: [output]

  stage:
    run: ./stage_workflow.cwl
    in:
      tumor: tumor_download/output
      tumor_index: tumor_index_download/output
      reference: reference_fa_download/output
      reference_fai: reference_fai_download/output
      reference_dict: reference_dict_download/output
      germline_ref: germline_resource_download/output
      germline_ref_index: germline_resource_index_download/output
      biallelic_ref: common_biallelic_variants_download/output
      biallelic_ref_index: common_biallelic_variants_index_download/output
      pon: panel_of_normal_download/output
      pon_index: panel_of_normal_index_download/output
    out: [tumor_with_index, reference_with_index, germline_ref_with_index, biallelic_ref_with_index, pon_with_index]
