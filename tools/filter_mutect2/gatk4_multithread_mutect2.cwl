#!/usr/bin/env cwl-runner

cwlVersion: v1.0

class: CommandLineTool

requirements:
  - class: InlineJavascriptRequirement
  - class: DockerRequirement
    dockerPull: {{ docker_repo }}/gatk4-mutect2-tool:{{ gatk4-mutect2-tool }}

inputs:
  # wrapper params
  nthreads:
    type: int
    inputBinding:
      prefix: --nthreads
  java_heap:
    type: string
    inputBinding:
      prefix: --java_heap
  # required params
  input:
    type:
      type: array
      items: ["null", File]
      inputBinding:
        prefix: --input
    secondaryFiles: [^.bai]
  output_prefix:
    type: string
    inputBinding:
      prefix: --output
  reference:
    type: File
    secondaryFiles: [.fai, ^.dict]
    inputBinding:
      prefix: --reference
  intervals:
    type: File
    inputBinding:
      prefix: --intervals
  # wrapper params
  bam_output:
    type: boolean
    default: true
    inputBinding:
      prefix: --bam-output
  f1r2_tar_gz:
    type: boolean
    default: true
    inputBinding:
      prefix: --f1r2-tar-gz
  gatk4_path:
    type: string
    default: "/usr/local/bin/gatk"
    inputBinding:
      prefix: --gatk4_path
  # optional params
  active_probability_threshold:
    type: float?
    inputBinding:
      prefix: --active-probability-threshold
  adaptive_pruning_initial_error_rate:
    type: float?
    inputBinding:
      prefix: --adaptive-pruning-initial-error-rate
  af_of_alleles_not_in_resource:
    type: float?
    inputBinding:
      prefix: --af-of-alleles-not-in-resource
  allow_non_unique_kmers_in_ref:
    type: boolean?
    inputBinding:
      prefix: --allow-non-unique-kmers-in-ref
  assembly_region_padding:
    type: int?
    inputBinding:
      prefix: --assembly-region-padding
  bam_writer_type:
    type: string?
    inputBinding:
      prefix: --bam-writer-type
  base_quality_score_threshold:
    type: int?
    inputBinding:
      prefix: --base-quality-score-threshold
  callable_depth:
    type: int?
    inputBinding:
      prefix: --callable-depth
  disable_adaptive_pruning:
    type: boolean?
    inputBinding:
      prefix: --disable-adaptive-pruning
  disable_bam_index_caching:
    type: boolean?
    inputBinding:
      prefix: --disable-bam-index-caching
  disable_sequence_dictionary_validation:
    type: boolean?
    inputBinding:
      prefix: --disable-sequence-dictionary-validation
  disable_tool_default_annotations:
    type: boolean?
    inputBinding:
      prefix: --disable-tool-default-annotations
  dont_increase_kmer_sizes_for_cycles:
    type: boolean?
    inputBinding:
      prefix: --dont-increase-kmer-sizes-for-cycles
  dont_trim_active_regions:
    type: boolean?
    inputBinding:
      prefix: --dont-trim-active-regions
  dont_use_soft_clipped_bases:
    type: boolean?
    inputBinding:
      prefix: --dont-use-soft-clipped-bases
  downsampling_stride:
    type: int?
    inputBinding:
      prefix: --downsampling-stride
  emit_ref_confidence:
    type: string?
    inputBinding:
      prefix: --emit-ref-confidence
  enable_all_annotations:
    type: boolean?
    inputBinding:
      prefix: --enable-all-annotations
  f1r2_max_depth:
    type: int?
    inputBinding:
      prefix: --f1r2-max-depth
  f1r2_median_mq:
    type: int?
    inputBinding:
      prefix: --f1r2-median-mq
  f1r2_min_bq:
    type: int?
    inputBinding:
      prefix: --f1r2-min-bq
  force_active:
    type: boolean?
    inputBinding:
      prefix: --force-active
  genotype_filtered_alleles:
    type: boolean?
    inputBinding:
      prefix: --genotype-filtered-alleles
  genotype_germline_sites:
    type: boolean?
    inputBinding:
      prefix: --genotype-germline-sites
  genotype_pon_sites:
    type: boolean?
    inputBinding:
      prefix: --genotype-pon-sites
  germline_resource:
    type: File?
    inputBinding:
      prefix: --germline-resource
    secondaryFiles: [.tbi]
  gvcf_lod_band:
    type: float?
    inputBinding:
      prefix: --gvcf-lod-band
  ignore_itr_artifacts:
    type: boolean?
    inputBinding:
      prefix: --ignore-itr-artifacts
  initial_tumor_lod:
    type: float?
    inputBinding:
      prefix: --initial-tumor-lod
  interval_merging_rule:
    type: string?
    inputBinding:
      prefix: --interval-merging-rule
  kmer_size:
    type: int?
    inputBinding:
      prefix: --kmer-size
  max_assembly_region_size:
    type: int?
    inputBinding:
      prefix: --max-assembly-region-size
  max_mnp_distance:
    type: int?
    inputBinding:
      prefix: --max-mnp-distance
  max_num_haplotypes_in_population:
    type: int?
    inputBinding:
      prefix: --max-num-haplotypes-in-population
  max_population_af:
    type: float?
    inputBinding:
      prefix: --max-population-af
  max_prob_propagation_distance:
    type: int?
    inputBinding:
      prefix: --max-prob-propagation-distance
  max_reads_per_alignment_start:
    type: int?
    inputBinding:
      prefix: --max-reads-per-alignment-start
  max_suspicious_reads_per_alignment_start:
    type: int?
    inputBinding:
      prefix: --max-suspicious-reads-per-alignment-start
  max_unpruned_variants:
    type: int?
    inputBinding:
      prefix: --max-unpruned-variants
  min_assembly_region_size:
    type: int?
    inputBinding:
      prefix: --min-assembly-region-size
  min_base_quality_score:
    type: int?
    inputBinding:
      prefix: --min-base-quality-score
  min_dangling_branch_length:
    type: int?
    inputBinding:
      prefix: --min-dangling-branch-length
  min_pruning:
    type: int?
    inputBinding:
      prefix: --min-pruning
  minimum_allele_fraction:
    type: float?
    inputBinding:
      prefix: --minimum-allele-fraction
  mitochondria_mode:
    type: boolean?
    inputBinding:
      prefix: --mitochondria-mode
  native_pair_hmm_threads:
    type: int?
    inputBinding:
      prefix: --native-pair-hmm-threads
  native_pair_hmm_use_double_precision:
    type: boolean?
    inputBinding:
      prefix: --native-pair-hmm-use-double-precision
  normal_lod:
    type: float?
    inputBinding:
      prefix: --normal-lod
  normal_sample:
    type: string[]?
    inputBinding:
      prefix: --normal-sample
  num_pruning_samples:
    type: int?
    inputBinding:
      prefix: --num-pruning-samples
  pair_hmm_gap_continuation_penalty:
    type: int?
    inputBinding:
      prefix: --pair-hmm-gap-continuation-penalty
  pair_hmm_implementation:
    type: string?
    inputBinding:
      prefix: --pair-hmm-implementation
  panel_of_normals:
    type: File?
    inputBinding:
      prefix: --panel-of-normals
    secondaryFiles: [.tbi]
  pcr_indel_model:
    type: string?
    inputBinding:
      prefix: --pcr-indel-model
  pcr_indel_qual:
    type: int?
    inputBinding:
      prefix: --pcr-indel-qual
  pcr_snv_qual:
    type: int?
    inputBinding:
      prefix: --pcr-snv-qual
  pedigree:
    type: File?
    inputBinding:
      prefix: --pedigree
  phred_scaled_global_read_mismapping_rate:
    type: int?
    inputBinding:
      prefix: --phred-scaled-global-read-mismapping-rate
  pruning_lod_threshold:
    type: float?
    inputBinding:
      prefix: --pruning-lod-threshold
  recover_all_dangling_branches:
    type: boolean?
    inputBinding:
      prefix: --recover-all-dangling-branches
  showHidden:
    type: boolean?
    inputBinding:
      prefix: --showHidden
  sites_only_vcf_output:
    type: boolean?
    inputBinding:
      prefix: --sites-only-vcf-output
  smith_waterman:
    type: string?
    inputBinding:
      prefix: --smith-waterman
  tumor_lod_to_emit:
    type: float?
    inputBinding:
      prefix: --tumor-lod-to-emit

outputs:
  vcfs:
    type: File[]
    outputBinding:
      glob: '*vcf.gz'
    secondaryFiles: [.tbi]

  reassembly:
    type: File[]?
    outputBinding:
      glob: '*reassembly.bam'
    secondaryFiles: [^.bai]

  f1r2s:
    type: File[]
    outputBinding:
      glob: '*tar.gz'

  stats:
    type: File[]
    outputBinding:
      glob: '*stats'

baseCommand: ['gatk4_mutect2_tool']