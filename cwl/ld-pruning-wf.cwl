cwlVersion: v1.2
class: Workflow
label: LD Pruning
doc: |-
  This workflow prunes variants to a subset not in linkage disequilibrium (LD) with each other
  and creates a new GDS file containing only the independent variants.

  LD is a measure of correlation of genotypes between a pair of variants. The pruning process
  filters variants so that those that remain have LD measures below a 
  given threshold. This procedure is typically used to identify a (nearly) independent subset of 
  variants. This is often the first step in evaluating relatedness and population structure to avoid 
  having results driven by clusters of variants in high LD regions of the genome.

  Recommended usage is to provide separate GDS files for each chromosome, in which case the workflow
  will scatter over the GDS files. Each file will be subset to only the pruned variants, then the
  subset files will be merged into a single output file with pruned variants from all chromosomes.
  A subsequent step verifies that the merge was performed correctly.
  If a single file is provided, the merge step will be skipped. In this case, variants from only
  one chromosome may be selected using the 'chromosome' input parameter. 'Chromosome' should not
  be specified when running on multiple files.

  A set of variants to be considered for pruning may be provided.
  Only one file is allowed as input, but it may contain all variant.ids for the
  combined set of input GDS files.

  There are two inputs for samples to include in the workflow. One set of sample IDs is used for
  the pruning step, and it is recommended to only include unrelated samples in this set
  if relationships are previously known. A different set of samples may be specified for
  inclusion in the output GDS file.

  In addition to the pruned GDS file, the workflow outputs RData files with vectors of variant.id
  identifying the pruned variants in each of the input GDS files. 
$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: ScatterFeatureRequirement
- class: InlineJavascriptRequirement
- class: StepInputExpressionRequirement

inputs:
- id: gds_file
  label: GDS files
  doc: Input GDS files, one per chromosome.
  type: File[]
  sbg:fileTypes: GDS
  sbg:x: -440
  sbg:y: 21
- id: sample_include_file_pruning
  label: Sample Include file for LD pruning
  doc: |-
    RData file with vector of sample.id to use for LD pruning (unrelated samples are recommended). If not provided, all samples in the GDS files are included.
  type: File?
  sbg:fileTypes: RDATA
  sbg:x: -482
  sbg:y: -175
- id: sample_include_file_gds
  label: Sample include file for output GDS
  doc: |-
    RData file with vector of sample.id to include in the output GDS. If not provided, all samples in the GDS files are included.
  type: File?
  sbg:fileTypes: RDATA
  sbg:x: -258
  sbg:y: 59
- id: variant_include_file
  label: Variant Include file for LD pruning
  doc: |-
    RData file with vector of variant.id to consider for LD pruning. If not provided, all variants in the GDS files are included.
  type: File?
  sbg:fileTypes: RDATA
  sbg:x: -427
  sbg:y: -303
- id: out_prefix
  label: Output prefix
  doc: Prefix for output files.
  type: string
  sbg:exposed: true
- id: autosome_only
  label: Autosomes only
  doc: Only include variants on the autosomes.
  type:
  - 'null'
  - name: autosome_only
    type: enum
    symbols:
    - "TRUE"
    - "FALSE"
  sbg:exposed: true
  sbg:toolDefaultValue: 'TRUE'
- id: exclude_pca_corr
  label: Exclude PCA corr
  doc: |-
    Exclude variants in genomic regions known to result in high PC-variant correlations when included (HLA, LCT, inversions).
  type: 
  - 'null'
  - name: exclude_pca_corr
    type: enum
    symbols:
    - "TRUE"
    - "FALSE"
  sbg:exposed: true
  sbg:toolDefaultValue: 'TRUE'
- id: genome_build
  label: Genome build
  doc: |-
    Genome build, used to define genomic regions to filter for PC-variant correlation.
  type:
  - 'null'
  - name: genome_build
    type: enum
    symbols:
    - hg18
    - hg19
    - hg38
  sbg:exposed: true
  sbg:toolDefaultValue: hg38
- id: ld_r_threshold
  label: LD |r| threshold
  doc: '|r| threshold for LD pruning.'
  type: float?
  sbg:exposed: true
  sbg:toolDefaultValue: 0.32 (r^2 = 0.1)
- id: ld_win_size
  label: LD window size
  doc: Sliding window size in Mb for LD pruning.
  type: float?
  sbg:exposed: true
  sbg:toolDefaultValue: '10'
- id: maf_threshold
  label: MAF threshold
  doc: |-
    Minimum MAF for variants used in LD pruning. Variants below this threshold are removed.
  type: float?
  sbg:exposed: true
  sbg:toolDefaultValue: '0.01'
- id: missing_threshold
  label: Missing call rate threshold
  doc: |-
    Maximum missing call rate for variants used in LD pruning. Variants above this threshold are removed.
  type: float?
  sbg:exposed: true
  sbg:toolDefaultValue: '0.01'
- id: chromosome
  label: Chromosome
  doc: |-
    If gds_file contains multiple chromosomes, the chromosome to run on.
  type: string?
  sbg:exposed: true

outputs:
- id: pruned_gds_output
  label: Pruned GDS output file
  doc: |-
    GDS output file containing sample genotypes at pruned variants from all chromosomes.
  type: File
  outputSource: # this fails validation in cwltool, but works on SBG
  - merge_gds/merged_gds_output # single file output
  - subset_gds/subset_gds_output # scattered file array output (but if merge is null, result will be a single file)
  pickValue: first_non_null
  sbg:fileTypes: GDS
  sbg:x: 351
  sbg:y: -214
- id: ld_pruning_output
  label: Pruned variant output file
  doc: RData file with variant.id of pruned variants.
  type: File[]
  outputSource:
  - ld_pruning/ld_pruning_output
  sbg:fileTypes: RDATA
  sbg:x: -61
  sbg:y: -287
- id: check_merged_output
  label: Results of check
  doc: |-
    PASS/FAIL indicator for whether contents of gds_file match the corresponding chromosome in merged_gds_file.
  type: string[]?
  outputSource:
  - check_merged_gds/check_merged_output
  sbg:x: 531
  sbg:y: -33

steps:
- id: ld_pruning
  label: ld_pruning
  in:
  - id: gds_file
    source: gds_file
  - id: out_file
    source: out_prefix
    valueFrom: |-
      ${
        return self + '_' + inputs.gds_file.nameroot + '_pruned_variants.RData'
      }
  - id: autosome_only
    source: autosome_only
  - id: exclude_pca_corr
    source: exclude_pca_corr
  - id: genome_build
    source: genome_build
  - id: ld_r_threshold
    source: ld_r_threshold
  - id: ld_win_size
    source: ld_win_size
  - id: maf_threshold
    source: maf_threshold
  - id: missing_threshold
    source: missing_threshold
  - id: sample_include_file
    source: sample_include_file_pruning
  - id: variant_include_file
    source: variant_include_file
  - id: chromosome
    source: chromosome
  scatter:
  - gds_file
  run: tools/ld_pruning.cwl
  out:
  - id: ld_pruning_output
  sbg:x: -259
  sbg:y: -159

- id: subset_gds
  label: subset_gds
  in:
  - id: gds_file
    source: gds_file
  - id: out_file
    source: out_prefix
    valueFrom: |-
      ${
        return self + '_' + inputs.gds_file.nameroot + '_pruned.gds'
      }
  - id: sample_include_file
    source: sample_include_file_gds
  - id: variant_include_file
    source: ld_pruning/ld_pruning_output
  scatter:
  - gds_file
  - variant_include_file
  scatterMethod: dotproduct
  run: tools/subset_gds.cwl
  out:
  - id: subset_gds_output
  sbg:x: -72
  sbg:y: -48

- id: merge_gds
  label: merge_gds
  in:
  - id: gds_file
    source:
    - subset_gds/subset_gds_output
  - id: out_file
    source: out_prefix
    valueFrom: |-
      ${
        return self + '_pruned.gds'
      }
  run: tools/merge_gds.cwl
  when: ${return inputs.gds_file.length > 1}
  out:
  - id: merged_gds_output
  sbg:x: 133
  sbg:y: -150

- id: check_merged_gds
  label: check_merged_gds
  in:
  - id: gds_file
    source: subset_gds/subset_gds_output
  - id: merged_gds_file
    source: merge_gds/merged_gds_output
  scatter:
  - gds_file
  run: tools/check_merged_gds.cwl
  when: ${return inputs.merged_gds_file != null}
  out:
  - id: check_merged_output
  sbg:x: 353
  sbg:y: -33

sbg:categories:
- GWAS
- Ancestry and Relatedness
- Linkage Disequilibrium
sbg:toolkit: UW-GAC Ancestry and Relatedness
