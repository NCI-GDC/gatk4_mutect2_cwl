#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

requirements:
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: ScatterFeatureRequirement

inputs:
  bioclient_config:
    type: File
  pon_calling:
    type: int[]
  has_normal:
    type: int[]
  tumor_gdc_id:
    type: string
  tumor_index_gdc_id:
    type: string
  normal_gdc_id:
    type: string?
  normal_index_gdc_id:
    type: string?
  reference_dict_gdc_id:
    type: string
  reference_fa_gdc_id:
    type: string
  reference_fai_gdc_id:
    type: string
  reference_image_gdc_id:
    type: string?
  germline_resource_gdc_id:
    type: string?
  germline_resource_index_gdc_id:
    type: string?
  common_biallelic_variants_gdc_id:
    type: string?
  common_biallelic_variants_index_gdc_id:
    type: string?
  panel_of_normal_gdc_id:
    type: string?
  panel_of_normal_index_gdc_id:
    type: string?

outputs:
  tumor_with_index:
    type: File
    outputSource: stage/tumor_with_index
  normal_with_index:
    type: File?
    outputSource: stage/normal_with_index
  reference_with_index:
    type: File
    outputSource: stage/reference_with_index
  reference_image:
    type: File
    outputSource: reference_image_download/output
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
    run: ../bio_client/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: tumor_gdc_id
    out: [output]

  tumor_index_download:
    run: ../bio_client/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: tumor_index_gdc_id
    out: [output]

  normal_download:
    run: ../bio_client/bio_client_download.cwl
    scatter: has_normal
    in:
      has_normal: has_normal
      config_file: bioclient_config
      download_handle: normal_gdc_id
    out: [output]

  normal_index_download:
    run: ../bio_client/bio_client_download.cwl
    scatter: has_normal
    in:
      has_normal: has_normal
      config_file: bioclient_config
      download_handle: normal_index_gdc_id
    out: [output]

  extract_normal:
    run: ../extract_from_conditional_array.cwl
    in:
      input_array: normal_download/output
    out: [input_file]

  extract_normal_index:
    run: ../extract_from_conditional_array.cwl
    in:
      input_array: normal_index_download/output
    out: [input_file]

  reference_dict_download:
    run: ../bio_client/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: reference_dict_gdc_id
    out: [output]

  reference_fa_download:
    run: ../bio_client/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: reference_fa_gdc_id
    out: [output]

  reference_fai_download:
    run: ../bio_client/bio_client_download.cwl
    in:
      config_file: bioclient_config
      download_handle: reference_fai_gdc_id
    out: [output]

  reference_image_download:
    run: ../bio_client/bio_client_download.cwl
    in:
      pon_calling: pon_calling
      config_file: bioclient_config
      download_handle: reference_image_gdc_id
    out: [output]

  germline_resource_download:
    run: ../bio_client/bio_client_download.cwl
    in:
      pon_calling: pon_calling
      config_file: bioclient_config
      download_handle: germline_resource_gdc_id
    out: [output]

  germline_resource_index_download:
    run: ../bio_client/bio_client_download.cwl
    in:
      pon_calling: pon_calling
      config_file: bioclient_config
      download_handle: germline_resource_index_gdc_id
    out: [output]

  common_biallelic_variants_download:
    run: ../bio_client/bio_client_download.cwl
    in:
      pon_calling: pon_calling
      config_file: bioclient_config
      download_handle: common_biallelic_variants_gdc_id
    out: [output]

  common_biallelic_variants_index_download:
    run: ../bio_client/bio_client_download.cwl
    in:
      pon_calling: pon_calling
      config_file: bioclient_config
      download_handle: common_biallelic_variants_index_gdc_id
    out: [output]

  panel_of_normal_download:
    run: ../bio_client/bio_client_download.cwl
    in:
      pon_calling: pon_calling
      config_file: bioclient_config
      download_handle: panel_of_normal_gdc_id
    out: [output]

  panel_of_normal_index_download:
    run: ../bio_client/bio_client_download.cwl
    in:
      pon_calling: pon_calling
      config_file: bioclient_config
      download_handle: panel_of_normal_index_gdc_id
    out: [output]

  stage:
    run: ./stage_workflow.cwl
    in:
      pon_calling: pon_calling
      has_normal: has_normal
      tumor: tumor_download/output
      tumor_index: tumor_index_download/output
      normal: extract_normal/input_file
      normal_index: extract_normal_index/input_file
      reference: reference_fa_download/output
      reference_fai: reference_fai_download/output
      reference_dict: reference_dict_download/output
      germline_ref: germline_resource_download/output
      germline_ref_index: germline_resource_index_download/output
      biallelic_ref: common_biallelic_variants_download/output
      biallelic_ref_index: common_biallelic_variants_index_download/output
      pon: panel_of_normal_download/output
      pon_index: panel_of_normal_index_download/output
    out: [tumor_with_index, normal_with_index, reference_with_index, germline_ref_with_index, biallelic_ref_with_index, pon_with_index]
