#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement

inputs:
###BIOCLIENT_INPUTS###
  bioclient_config: File
  tumor_gdc_id: string
  tumor_index_gdc_id: string
  reference_gdc_id: string
  reference_faidx_gdc_id: string
  reference_dict_gdc_id: string
  germline_resource_gdc_id: string
  germline_resource_index_gdc_id: string
  common_biallelic_variants_gdc_id: string
  common_biallelic_variants_index_gdc_id: string
  panel_of_normal_gdc_id: string
  panel_of_normal_index_gdc_id: string
  upload_bucket: string
###GENERAL_INPUTS###
  project_id: string?
  experimental_strategy: string?
  usedecoy:
    type: boolean
    default: false
    doc: If specified, it will include all the decoy sequences in the faidx. GDC default is false.
  java_heap:
    type: string
    default: '3G'
    doc: Java option flags for all the java cmd. GDC default is 3G.
  job_uuid:
    type: string
    doc: Job id. Served as a prefix for most outputs.
  threads:
    type: int
    default: 8
    doc: Threads for internal multithreading dockers.
  duscb:
    type: boolean
    default: false
    doc: MuTect2 parameter. GDC default is False. If set, MuTect2 will not use soft clipped bases.
  af_of_alleles_not_in_resource:
    type: float
    default: 0.0000025
    doc: Population allele fraction assigned to alleles not found in germline resource. A reasonable value is 1/(2* number of samples in resource) if a germline resource is available; otherwise an average heterozygosity rate such as 0.001 is reasonable.
  artifact_modes:
    type: string[]
    default: ["G/T", "C/T"]
    doc: Sequencing contexts for FFPE (C→T transition) and OxoG (G→T transversion).

outputs:
  single_tumor_vcf_uuid:
    type: string
    outputSource: uuid_single_tumor_vcf/output
  single_tumor_vcf_index_uuid:
    type: File
    outputSource: uuid_single_tumor_vcf_index/output

steps:
  prepare_file_prefix:
    run: ../utils-cwl/make_prefix.cwl
    in:
      project_id: project_id
      job_id: job_uuid
      experimental_strategy: experimental_strategy
  out: [output_prefix]

  preparation:
    run: ../utils-cwl/subworkflow/preparation_workflow.cwl
    in:
      bioclient_config: bioclient_config
      tumor_gdc_id: tumor_gdc_id
      tumor_index_gdc_id: tumor_index_gdc_id
      reference_fa_gdc_id: reference_gdc_id
      reference_fai_gdc_id: reference_faidx_gdc_id
      reference_dict_gdc_id: reference_dict_gdc_id
      germline_resource_gdc_id: germline_resource_gdc_id
      germline_resource_index_gdc_id: germline_resource_index_gdc_id
      common_biallelic_variants_gdc_id: common_biallelic_variants_gdc_id
      common_biallelic_variants_index_gdc_id: common_biallelic_variants_index_gdc_id
      panel_of_normal_gdc_id: panel_of_normal_gdc_id
      panel_of_normal_index_gdc_id: panel_of_normal_index_gdc_id
    out: [tumor_with_index, reference_with_index, germline_resource_with_index, common_biallelic_variants_with_index, panel_of_normal_with_index]

  faidx_to_bed:
    run: ../utils-cwl/faidx_to_bed.cwl
    in:
      ref_fai:
        source: preparation/reference_with_index
        valueFrom: $(self.secondaryFiles[0])
      usedecoy: usedecoy
    out: [output_bed]

  get_tumor_sample_name:
    run: ../tools/gatk4_getsamplename.cwl
    in:
      java_heap: java_heap
      input: preparation/tumor_with_index
      output:
        source: prepare_file_prefix/output_prefix
        valueFrom: $(self + '.sample_name')
    out: [samplename]

  get_oxog_metrics:
    run: ../tools/gatk4_collectsequencingartifactmetrics.cwl
    in:
      java_heap: java_heap
      input: preparation/tumor_with_index
      output: job_uuid
      reference: preparation/reference_with_index
    out: [metrics]

  mutect2_call:
    run: ../tools/multi_gatk4_mutect2_single_tumor.cwl
    in:
      threads: threads
      java_heap: java_heap
      input: preparation/tumor_with_index
      reference: preparation/reference_with_index
      tumor_sample: get_tumor_sample_name/samplename
      af_of_alleles_not_in_resource: af_of_alleles_not_in_resource
      germline_resource: preparation/germline_resource_with_index
      intervals: faidx_to_bed/output_bed
      panel_of_normals: preparation/panel_of_normal_with_index
      dont_use_soft_clipped_bases: duscb
    out: [output_vcf]

  sort_vcf:
    run: ../tools/picard-sortvcf.cwl
    in:
      ref_dict:
        source: preparation/reference_with_index
        valueFrom: $(self.secondaryFiles[1])
      output_vcf:
        source: prepare_file_prefix/output_prefix
        valueFrom: $(self + '.mutect2.singletumor.sorted.vcf.gz')
      input_vcf:
        source: mutect2_call/output_vcf
        valueFrom: $([self])
    out: [sorted_vcf]

  getpileupsummaries_on_tumor:
    run: ../tools/gatk4_getpileupsummaries.cwl
    in:
      java_heap: java_heap
      input: preparation/tumor_with_index
      output:
        source: prepare_file_prefix/output_prefix
        valueFrom: $(self + '.table')
      variant: preparation/common_biallelic_variants_with_index
      intervals: faidx_to_bed/output_bed
      reference: preparation/reference_with_index
    out: [pileup_table]

  calculatecontamination_on_tumor:
    run: ../tools/gatk4_calculatecontamination.cwl
    in:
      java_heap: java_heap
      input: getpileupsummaries_on_tumor/pileup_table
      output:
        source: prepare_file_prefix/output_prefix
        valueFrom: $(self + '.contamination.table')
    out: [contamination_table]

  filtermutectcalls:
    run: ../tools/gatk4_filtermutectcalls.cwl
    in:
      java_heap: java_heap
      output:
        source: prepare_file_prefix/output_prefix
        valueFrom: $(self + '.mutect2.singletumor.contFiltered.vcf.gz')
      variant: sort_vcf/sorted_vcf
      contamination_table: calculatecontamination_on_tumor/contamination_table
      intervals: faidx_to_bed/output_bed
    out: [filtered_vcf]

  filterbyorientationbias:
    run: ../tools/gatk4_filterbyorientationbias.cwl
    in:
      java_heap: java_heap
      output:
        source: prepare_file_prefix/output_prefix
        valueFrom: $(self + '.mutect2.singletumor.contFiltered.oxogFiltered.vcf.gz')
      pre_adapter_detail_file: get_oxog_metrics/metrics
      variant: filtermutectcalls/filtered_vcf
      intervals: faidx_to_bed/output_bed
      reference: preparation/reference_with_index
      artifact_modes: artifact_modes
    out: [oxog_filtered_vcf]

  upload_single_tumor_vcf:
    run: ../utils-cwl/bio_client/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [job_uuid, filterbyorientationbias/oxog_filtered_vcf]
        valueFrom: $(self[0])/$(self[1].basename)
      local_file: filterbyorientationbias/oxog_filtered_vcf
    out: [output]

  upload_single_tumor_vcf_index:
    run: ../utils-cwl/bio_client/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [job_uuid, filterbyorientationbias/oxog_filtered_vcf]
        valueFrom: $(self[0])/$(self[1].secondaryFiles[0].basename)
      local_file:
        source: filterbyorientationbias/oxog_filtered_vcf
        valueFrom: $(self.secondaryFiles[0])
    out: [output]

  uuid_single_tumor_vcf:
    run: ../utils-cwl/emit_json_value.cwl
    in:
      input: upload_single_tumor_vcf/output
      key:
       valueFrom: 'did'
    out: [output]

  uuid_single_tumor_vcf_index:
    run: ../utils-cwl/emit_json_value.cwl
    in:
      input: upload_single_tumor_vcf_index/output
      key:
        valueFrom: 'did'
    out: [output]
