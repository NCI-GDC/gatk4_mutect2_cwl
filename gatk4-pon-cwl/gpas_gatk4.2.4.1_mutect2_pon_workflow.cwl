#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: Workflow

requirements:
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: MultipleInputFeatureRequirement
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement

inputs:
###BIOCLIENT_INPUTS###
  bioclient_config: File
  tumor_gdc_id: string
  tumor_index_gdc_id: string
  reference_gdc_id: string
  reference_faidx_gdc_id: string
  reference_dict_gdc_id: string
  reference_image_gdc_id: string
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
  job_uuid:
    type: string
    doc: Job id. Served as a prefix for most outputs.
  chunk_java_heap:
    type: string
    default: '3G'
    doc: Java option flag for multithreading Mutect2 only. GDC default is 3G.
  nthreads: int
  bam_output:
    type: boolean
    default: false
    doc: If specified, assembled haplotypes wil be written to bam. Used for alignment artifacts filtration. GDC default is true.
  f1r2_tar_gz:
    type: boolean
    default: false
    doc: If specified, collect F1R2 counts and output files into tar.gz file. Used for Mutect2 filtration. GDC default is true.
  usedecoy:
    type: boolean
    default: false
    doc: If specified, it will include all the decoy sequences in the faidx. GDC default is false.
  max_mnp_distance:
    type: int
    default: 0

###OPTIONAL_INPUTS###
  active_probability_threshold:
    type: float?
  adaptive_pruning_initial_error_rate:
    type: float?
  af_of_alleles_not_in_resource:
    type: float?
  allow_non_unique_kmers_in_ref:
    type: boolean?
  assembly_region_padding:
    type: int?
  bam_writer_type:
    type: string?
  base_quality_score_threshold:
    type: int?
  callable_depth:
    type: int?
  disable_adaptive_pruning:
    type: boolean?
  disable_bam_index_caching:
    type: boolean?
  disable_sequence_dictionary_validation:
    type: boolean?
  disable_tool_default_annotations:
    type: boolean?
  dont_increase_kmer_sizes_for_cycles:
    type: boolean?
  dont_trim_active_regions:
    type: boolean?
  dont_use_soft_clipped_bases:
    type: boolean?
  downsampling_stride:
    type: int?
  emit_ref_confidence:
    type: string?
  enable_all_annotations:
    type: boolean?
  f1r2_max_depth:
    type: int?
  f1r2_median_mq:
    type: int?
  f1r2_min_bq:
    type: int?
  force_active:
    type: boolean?
  genotype_filtered_alleles:
    type: boolean?
  genotype_germline_sites:
    type: boolean?
  genotype_pon_sites:
    type: boolean?
  gvcf_lod_band:
    type: float?
  ignore_itr_artifacts:
    type: boolean?
  initial_tumor_lod:
    type: float?
  interval_merging_rule:
    type: string?
  kmer_size:
    type: int?
  max_assembly_region_size:
    type: int?
  max_num_haplotypes_in_population:
    type: int?
  max_population_af:
    type: float?
  max_prob_propagation_distance:
    type: int?
  max_reads_per_alignment_start:
    type: int?
  max_suspicious_reads_per_alignment_start:
    type: int?
  max_unpruned_variants:
    type: int?
  min_assembly_region_size:
    type: int?
  min_base_quality_score:
    type: int?
  min_dangling_branch_length:
    type: int?
  min_pruning:
    type: int?
  minimum_allele_fraction:
    type: float?
  mitochondria_mode:
    type: boolean?
  native_pair_hmm_threads:
    type: int?
  native_pair_hmm_use_double_precision:
    type: boolean?
  num_pruning_samples:
    type: int?
  pair_hmm_gap_continuation_penalty:
    type: int?
  pair_hmm_implementation:
    type: string?
  pcr_indel_model:
    type: string?
  pcr_indel_qual:
    type: int?
  pcr_snv_qual:
    type: int?
  pedigree:
    type: File?
  phred_scaled_global_read_mismapping_rate:
    type: int?
  pruning_lod_threshold:
    type: float?
  recover_all_dangling_branches:
    type: boolean?
  showHidden:
    type: boolean?
  sites_only_vcf_output:
    type: boolean?
  smith_waterman:
    type: string?
  tumor_lod_to_emit:
    type: float?

outputs:
  individual_pon_vcf_uuid:
    type: string
    outputSource: uuid_vcf/output
  individual_pon_vcf_index_uuid:
    type: string
    outputSource: uuid_vcf_index/output

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
      reference_image_gdc_id: reference_image_gdc_id
      germline_resource_gdc_id: germline_resource_gdc_id
      germline_resource_index_gdc_id: germline_resource_index_gdc_id
      common_biallelic_variants_gdc_id: common_biallelic_variants_gdc_id
      common_biallelic_variants_index_gdc_id: common_biallelic_variants_index_gdc_id
      panel_of_normal_gdc_id: panel_of_normal_gdc_id
      panel_of_normal_index_gdc_id: panel_of_normal_index_gdc_id
    out: [tumor_with_index, normal_with_index, reference_with_index, reference_image, germline_resource_with_index, common_biallelic_variants_with_index, panel_of_normal_with_index]

  faidx_to_bed:
    run: ../utils-cwl/faidx_to_bed.cwl
    in:
      ref_fai:
        source: preparation/reference_with_index
        valueFrom: $(self.secondaryFiles[0])
      usedecoy: usedecoy
    out: [output_bed]

  gatk4_pon:
    run: ../tools/filter_mutect2/gatk4_multithread_mutect2.cwl
    in:
      nthreads: nthreads
      java_heap: chunk_java_heap
      input:
        source: [preparation/tumor_with_index]
      output_prefix: prepare_file_prefix/output_prefix
      reference: preparation/reference_with_index
      intervals: faidx_to_bed/output_bed
      bam_output: bam_output
      f1r2_tar_gz: f1r2_tar_gz
      active_probability_threshold: active_probability_threshold
      adaptive_pruning_initial_error_rate: adaptive_pruning_initial_error_rate
      af_of_alleles_not_in_resource: af_of_alleles_not_in_resource
      allow_non_unique_kmers_in_ref: allow_non_unique_kmers_in_ref
      assembly_region_padding: assembly_region_padding
      bam_writer_type: bam_writer_type
      base_quality_score_threshold: base_quality_score_threshold
      callable_depth: callable_depth
      disable_adaptive_pruning: disable_adaptive_pruning
      disable_bam_index_caching: disable_bam_index_caching
      disable_sequence_dictionary_validation: disable_sequence_dictionary_validation
      disable_tool_default_annotations: disable_tool_default_annotations
      dont_increase_kmer_sizes_for_cycles: dont_increase_kmer_sizes_for_cycles
      dont_trim_active_regions: dont_trim_active_regions
      dont_use_soft_clipped_bases: dont_use_soft_clipped_bases
      downsampling_stride: downsampling_stride
      emit_ref_confidence: emit_ref_confidence
      enable_all_annotations: enable_all_annotations
      f1r2_max_depth: f1r2_max_depth
      f1r2_median_mq: f1r2_median_mq
      f1r2_min_bq: f1r2_min_bq
      force_active: force_active
      genotype_filtered_alleles: genotype_filtered_alleles
      genotype_germline_sites: genotype_germline_sites
      genotype_pon_sites: genotype_pon_sites
      germline_resource: preparation/germline_resource_with_index
      gvcf_lod_band: gvcf_lod_band
      ignore_itr_artifacts: ignore_itr_artifacts
      initial_tumor_lod: initial_tumor_lod
      interval_merging_rule: interval_merging_rule
      kmer_size: kmer_size
      max_assembly_region_size: max_assembly_region_size
      max_mnp_distance: max_mnp_distance
      max_num_haplotypes_in_population: max_num_haplotypes_in_population
      max_population_af: max_population_af
      max_prob_propagation_distance: max_prob_propagation_distance
      max_reads_per_alignment_start: max_reads_per_alignment_start
      max_suspicious_reads_per_alignment_start: max_suspicious_reads_per_alignment_start
      max_unpruned_variants: max_unpruned_variants
      min_assembly_region_size: min_assembly_region_size
      min_base_quality_score: min_base_quality_score
      min_dangling_branch_length: min_dangling_branch_length
      min_pruning: min_pruning
      minimum_allele_fraction: minimum_allele_fraction
      mitochondria_mode: mitochondria_mode
      native_pair_hmm_threads: native_pair_hmm_threads
      native_pair_hmm_use_double_precision: native_pair_hmm_use_double_precision
      num_pruning_samples: num_pruning_samples
      pair_hmm_gap_continuation_penalty: pair_hmm_gap_continuation_penalty
      pair_hmm_implementation: pair_hmm_implementation
      panel_of_normals: preparation/panel_of_normal_with_index
      pcr_indel_model: pcr_indel_model
      pcr_indel_qual: pcr_indel_qual
      pcr_snv_qual: pcr_snv_qual
      pedigree: pedigree
      phred_scaled_global_read_mismapping_rate: phred_scaled_global_read_mismapping_rate
      pruning_lod_threshold: pruning_lod_threshold
      recover_all_dangling_branches: recover_all_dangling_branches
      showHidden: showHidden
      sites_only_vcf_output: sites_only_vcf_output
      smith_waterman: smith_waterman
      tumor_lod_to_emit: tumor_lod_to_emit
    out: [vcfs, reassembly, f1r2s, stats]

  upload_vcf:
    run: ../utils-cwl/bio_client/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [job_uuid, gatk4_pon/vcfs]
        valueFrom: $(self[0])/$(self[1].basename)
      local_file: gatk4_pon/vcfs
    out: [output]

  upload_vcf_index:
    run: ../utils-cwl/bio_client/bio_client_upload_pull_uuid.cwl
    in:
      config_file: bioclient_config
      upload_bucket: upload_bucket
      upload_key:
        source: [job_uuid, gatk4_pon/vcfs]
        valueFrom: $(self[0])/$(self[1].secondaryFiles[0].basename)
      local_file:
        source: gatk4_pon/vcfs
        valueFrom: $(self.secondaryFiles[0])
    out: [output]

  uuid_vcf:
    run: ../utils-cwl/emit_json_value.cwl
    in:
      input: upload_vcf/output
      key:
       valueFrom: 'did'
    out: [output]

  uuid_vcf_index:
    run: ../utils-cwl/emit_json_value.cwl
    in:
      input: upload_vcf_index/output
      key:
        valueFrom: 'did'
    out: [output]