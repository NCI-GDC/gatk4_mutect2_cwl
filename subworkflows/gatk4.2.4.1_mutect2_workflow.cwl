#!/usr/bin/env cwl-runner

cwlVersion: v1.0

doc: |
    GATK4.2.4.1 Mutect2 workflow

class: Workflow

requirements:
  - class: SubworkflowFeatureRequirement

inputs:
  has_normal: int[]
  output_prefix: string
  java_heap: string
  chunk_java_heap: string
  nthreads: int
  reference:
    type: File
    secondaryFiles: [.fai, ^.dict]
  reference_image: File
  common_variant_reference:
    type: File
    secondaryFiles: [.tbi]
  intervals: File
  tumor_bam:
    type: File
    secondaryFiles: [^.bai]
  normal_bam:
    type: File?
    secondaryFiles: [^.bai]
  bam_output:
    type: boolean
    default: true
  f1r2_tar_gz:
    type: boolean
    default: true
  call_on_all: boolean
  # optional params
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
  germline_resource:
    type: File?
    secondaryFiles: [.tbi]
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
  max_mnp_distance:
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
  normal_lod:
    type: float?
  num_pruning_samples:
    type: int?
  pair_hmm_gap_continuation_penalty:
    type: int?
  pair_hmm_implementation:
    type: string?
  panel_of_normals:
    type: File?
    secondaryFiles: [.tbi]
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
  gatk4.2.4.1_mutect2_filtered_vcf:
    type: File
    outputSource: modify_vcf_sample/gdc_gatk4_mutect2_vcf

steps:
  calculate_contamination:
    run: calculate_contamination_workflow.cwl
    in:
      has_normal: has_normal
      output_prefix: output_prefix
      java_heap: java_heap
      reference: reference
      common_variant_reference: common_variant_reference
      intervals: intervals
      tumor_bam: tumor_bam
      normal_bam: normal_bam
    out: [contamination_table, tumor_segments_table]

  mutect2_calling:
    run: mutect2_calling.cwl
    in:
      has_normal: has_normal
      java_heap: java_heap
      output_prefix: output_prefix
      nthreads: nthreads
      chunk_java_heap: chunk_java_heap
      tumor_bam: tumor_bam
      normal_bam: normal_bam
      reference: reference
      intervals: intervals
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
      germline_resource: germline_resource
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
      normal_lod: normal_lod
      num_pruning_samples: num_pruning_samples
      pair_hmm_gap_continuation_penalty: pair_hmm_gap_continuation_penalty
      pair_hmm_implementation: pair_hmm_implementation
      panel_of_normals: panel_of_normals
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
    out: [mutect2_vcf, mutect2_stats, mutect2_artifacts_priors, mutect2_reassembly_bamouts]

  filter_mutect2:
    run: ../tools/filter_mutect2/filter_mutect_calls.cwl
    in:
      java_heap: java_heap
      unfiltered_vcf: mutect2_calling/mutect2_vcf
      reference: reference
      output_prefix: output_prefix
      contamination_table: calculate_contamination/contamination_table
      tumor_segments_table: calculate_contamination/tumor_segments_table
      artifacts_priors: mutect2_calling/mutect2_artifacts_priors
      mutect2_stats: mutect2_calling/mutect2_stats
    out: [filtered_vcf]

  filter_alignment_artifacts:
    run: filter_alignment_artifacts.cwl
    in:
      java_heap: java_heap
      output_prefix: output_prefix
      reference: reference
      reference_image: reference_image
      input_vcf: filter_mutect2/filtered_vcf
      bam_outs: mutect2_calling/mutect2_reassembly_bamouts
      call_on_all: call_on_all
    out: [alignment_artifacts_filtered_vcf]

  modify_vcf_sample:
    run: ../tools/modify_vcf_sample.cwl
    in:
      tumor_bam: tumor_bam
      normal_bam: normal_bam
      vcf: filter_alignment_artifacts/alignment_artifacts_filtered_vcf
      output_prefix: output_prefix
    out: [gdc_gatk4_mutect2_vcf]