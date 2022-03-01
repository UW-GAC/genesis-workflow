cwlVersion: v1.2
class: Workflow
label: PC-AiR
doc: |-
  This workflow uses the PC-AiR algorithm to compute ancestry principal components (PCs) 
  while accounting for kinship.

  Step 1 uses pairwise kinship estimates to assign samples to an unrelated set that is 
  representative of all ancestries in the sample. Step 2 performs Principal Component 
  Analysis (PCA) on the unrelated set, then projects relatives onto the resulting set of 
  PCs. Step 3 plots the PCs, optionally color-coding by a grouping variable. Step 4 
  (optional) calculates the correlation between each PC and variants in the dataset, 
  then plots this correlation to allow screening for PCs that are driven by particular 
  genomic regions.

  To identify the unrelated set, the user supplies a pairwise kinship matrix. For large
  sample sizes, it is recommended to use the sparse Matrix object output by the 
  KING-IBDseg workflow. The default threshold considers 3rd-degree and closer relative pairs
  to be 'related', but this threshold may be changed by the user. Optionally, a dense
  matrix from the KING-robust workflow may be provided as the divergence matrix, which allows
  the algorithm to identify an optimal related set representing the most diversity in
  ancestry. Only KING-robust kinship estimates have the negative values required to identify
  ancestry divergence, so other kinship estimates are not suitable for this parameter.
  Including this file is helpful for smaller sample sizes, but for very large sample sizes,
  the computational burden is considerable and the improvement in sample selection is
  minimal.

  In some isolated populations, the median kinship value may be elevated. In a large study
  containing both isolated and general populations, using the same kinship threshold for
  all pairs in the study may not be appropriate. If a phenotype file with a 'group'
  column identifying population for each sample is provided, the algorithm will identify
  groups with elevated overall kinship and adjust the kinship threshold for pairs of
  samples within those groups as necessary.

  The GDS file supplied for calculating principal components should be LD pruned to
  independent variants with the LD-pruning workflow. One file containing all chromosomes
  is required.

  To calculate the correlation between variants and PCs, set the 'run correlation'
  parameter to TRUE. This option requires two additional inputs; full GDS files 
  containing all variants, and RData files containing the variant IDs for LD-pruned 
  variants (output by the LD-pruning workflow). Each of these inputs is an array of
  files by chromosome, and the workflow scatters over each GDS/variant file pair.
  The set of variants used in the corrlelation is a random sample of variants from
  the full GDS file, along with the entire set of pruned variants. The random sample
  is taken to reduce computation time.

  The workflow has several outputs; 1) RData files with vectors of unrelated and
  related sample ids, 2) RData file with a 'pcair' object containing PCs for all 
  samples, 3) plots showing PCs, color-coded by group if a phenotype file was
  provided, 4) (optionally) GDS files containing PC-variant correlation values,
  5) (optionally) plots showing PC-variant correlation.
$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: SubworkflowFeatureRequirement
- class: InlineJavascriptRequirement
- class: StepInputExpressionRequirement

inputs:
- id: out_prefix
  label: Output prefix
  doc: Prefix for output files.
  type: string
  sbg:exposed: true
- id: kinship_file
  label: Kinship File
  doc: |-
    Pairwise kinship matrix used to identify unrelated and related sets of samples in Step 1. It is recommended to use KING-IBDseg or PC-Relate estimates.
  type: File
  sbg:fileTypes: RDATA, GDS
  sbg:x: -590
  sbg:y: 68
- id: divergence_file
  label: Divergence File
  doc: |-
    Pairwise matrix used to identify ancestrally divergent pairs of samples in Step 1. It is recommended to use KING-robust estimates.
  type: File?
  sbg:fileTypes: RDATA, GDS
  sbg:x: -575
  sbg:y: 207
- id: gds_file
  label: Pruned GDS File
  doc: |-
    Input GDS file for PCA. It is recommended to use an LD pruned file with all chromosomes.
  type: File
  sbg:fileTypes: GDS
  sbg:x: -381
  sbg:y: 127
- id: sample_include_file
  label: Sample Include file
  doc: |-
    RData file with vector of sample.id to include. If not provided, all samples in the GDS file are included.
  type: File?
  sbg:fileTypes: RDATA
  sbg:x: -591
  sbg:y: -74
- id: variant_include_file
  label: Variant include file
  doc: |-
    RData file with vector of variant.id to include. If not provided, all variants in the GDS file are included.
  type: File?
  sbg:fileTypes: RDATA
  sbg:x: -345
  sbg:y: -246
- id: phenotype_file
  label: Phenotype file
  doc: |-
    RData file with data.frame or AnnotatedDataFrame of phenotypes. Used for color-coding PCA plots by group.
  type: File?
  sbg:fileTypes: RDATA
  sbg:x: -538
  sbg:y: -214
- id: kinship_threshold
  label: Kinship threshold
  doc: Minimum kinship estimate to use for identifying relatives.
  type: float?
  sbg:exposed: true
  sbg:toolDefaultValue: 2^(-9/2) (third-degree relatives and closer)
- id: divergence_threshold
  label: Divergence threshold
  doc: |-
    Maximum divergence estimate to use for identifying ancestrally divergent pairs of samples.
  type: float?
  sbg:exposed: true
  sbg:toolDefaultValue: -2^(-9/2)
- id: n_pcs
  label: Number of PCs
  doc: Number of PCs (Principal Components) to return.
  type: int?
  sbg:toolDefaultValue: '32'
  sbg:exposed: true
- id: n_pairs
  label: Number of PCs
  doc: Number of PCs to include in the pairs plot.
  type: int?
  sbg:toolDefaultValue: '6'
  sbg:exposed: true
- id: group
  label: Group
  doc: |-
    Name of column in phenotype_file containing group variable.
  type: string?
  sbg:exposed: true
- id: run_correlation
  label: Run PC-variant correlation
  doc: |-
    For pruned variants as well as a random sample of additional variants, compute correlation between the variants and PCs, and generate plots. This step can be computationally intensive, but is useful for verifying that PCs are not driven by small regions of the genome.
  type: boolean
  sbg:exposed: true
- id: gds_file_full
  label: Full GDS Files
  doc: GDS files (one per chromosome) used to calculate PC-variant correlations.
  type: File[]?
  sbg:fileTypes: GDS
  sbg:x: -313
  sbg:y: 304
- id: pruned_variant_file
  label: Pruned variant files
  doc: |-
    RData files (one per chromosome) with vector of variant.id produced by the LD pruning workflow. These variants will be added to the set of randomly selected variants.
  type: File[]?
  sbg:fileTypes: RDATA
  sbg:x: -213
  sbg:y: 189
- id: n_corr_vars
  label: Number of variants to select
  doc: |-
    Randomly select this number of variants distributed across the entire genome to use for PC-variant correlation. If running on a single chromosome, the variants returned will be scaled by the proportion of that chromosome in the genome.
  type: int?
  sbg:toolDefaultValue: '10e6'
  sbg:exposed: true
- id: n_pcs_corr
  label: Number of PCs
  doc: Number of PCs (Principal Components) to use for PC-variant correlation
  type: int?
  sbg:toolDefaultValue: '32'
  sbg:exposed: true
- id: n_pcs_plot
  label: Number of PCs to plot
  doc: Number of PCs to plot in PC-variant correlation plots.
  type: int?
  sbg:toolDefaultValue: '20'
  sbg:exposed: true
- id: n_perpage
  label: Number of plots per page
  doc: |-
    Number of PC-variant correlation plots to stack in a single page. The number of png files generated will be ceiling(n_pcs_plot/n_perpage).
  type: int?
  sbg:toolDefaultValue: '4'
  sbg:exposed: true
- id: thin_corr_plots
  label: Thin PC-variant correlation plots
  doc: Thin points in PC-variant correlation plots to reduce time to create the plots
  type:
  - 'null'
  - name: thin
    type: enum
    symbols:
    - "TRUE"
    - "FALSE"
  sbg:toolDefaultValue: 'true'
  sbg:exposed: true
- id: cpu
  label: cpu
  doc: Number of CPUs to use.
  type: int?
  sbg:toolDefaultValue: '4'
  sbg:exposed: true


outputs:
- id: out_unrelated_file
  label: Unrelated file
  doc: RData file with vector of sample.id of unrelated samples identified in Step 1
  type: File
  outputSource:
  - find_unrelated/out_unrelated_file
  sbg:fileTypes: RDATA
  sbg:x: -110
  sbg:y: -279
- id: out_related_file
  label: Related file
  doc: |-
    RData file with vector of sample.id of samples related to the set of unrelated samples identified in Step 1
  type: File
  outputSource:
  - find_unrelated/out_related_file
  sbg:fileTypes: RDATA
  sbg:x: -20
  sbg:y: -170
- id: pcair_output
  label: PC-AiR PCs
  doc: RData file with PC-AiR PCs for all samples
  type: File
  outputSource:
  - pca_byrel/pcair_output
  sbg:fileTypes: RDATA
  sbg:x: 372
  sbg:y: -50
- id: pcair_plots
  label: PC plots
  doc: PC plots
  type: File[]
  outputSource:
  - pca_plots/pca_plots
  sbg:x: 471
  sbg:y: -205
- id: pc_correlation_plots
  label: PC-variant correlation plots
  doc: PC-variant correlation plots
  type: File[]?
  outputSource:
  - pc_variant_correlation/pc_correlation_plots
  sbg:fileTypes: PNG
  sbg:x: 332
  sbg:y: 208
- id: pca_corr_gds
  label: PC-variant correlation
  doc: GDS file with PC-variant correlation results
  type: File[]?
  outputSource:
  - pc_variant_correlation/pca_corr_gds
  sbg:fileTypes: GDS
  sbg:x: 285
  sbg:y: 85

steps:
- id: find_unrelated
  label: find_unrelated
  in:
  - id: kinship_file
    source: kinship_file
  - id: divergence_file
    source: divergence_file
  - id: kinship_threshold
    source: kinship_threshold
  - id: divergence_threshold
    source: divergence_threshold
  - id: sample_include_file
    source: sample_include_file
  - id: phenotype_file
    source: phenotype_file
  - id: group
    source: group
  - id: out_prefix
    source: out_prefix
  run: tools/find_unrelated.cwl
  out:
  - id: out_related_file
  - id: out_unrelated_file
  sbg:x: -343
  sbg:y: -80
- id: pca_byrel
  label: pca_byrel
  in:
  - id: gds_file
    source: gds_file
  - id: related_file
    source: find_unrelated/out_related_file
  - id: unrelated_file
    source: find_unrelated/out_unrelated_file
  - id: sample_include_file
    source: sample_include_file
  - id: variant_include_file
    source: variant_include_file
  - id: n_pcs
    source: n_pcs
  - id: out_prefix
    source: out_prefix
  - id: cpu
    source: cpu
  run: tools/pca_byrel.cwl
  out:
  - id: pcair_output
  - id: pcair_output_unrelated
  sbg:x: -94
  sbg:y: -19
- id: pca_plots
  label: pca_plots
  in:
  - id: pca_file
    source: pca_byrel/pcair_output
  - id: phenotype_file
    source: phenotype_file
  - id: n_pairs
    source: n_pairs
  - id: group
    source: group
  - id: out_prefix
    source: out_prefix
  run: tools/pca_plots.cwl
  out:
  - id: pca_plots
  sbg:x: 206
  sbg:y: -174
- id: pc_variant_correlation
  label: PC-variant correlation
  in:
  - id: out_prefix
    source: out_prefix
  - id: gds_file_full
    source: gds_file_full
  - id: variant_include_file
    source: pruned_variant_file
  - id: pca_file
    source: pca_byrel/pcair_output_unrelated
  - id: n_corr_vars
    source: n_corr_vars
  - id: n_pcs_corr
    source: n_pcs_corr
  - id: n_pcs_plot
    source: n_pcs_plot
  - id: n_perpage
    source: n_perpage
  - id: thin_corr_plots
    source: thin_corr_plots
  - id: cpu
    source: cpu
  - id: run_correlation
    source: run_correlation
  run: pc_variant_correlation.cwl
  when: $(inputs.run_correlation)
  out:
  - id: pc_correlation_plots
  - id: pca_corr_gds
  sbg:x: 85
  sbg:y: 199
sbg:categories:
- GWAS
- Ancestry and Relatedness
sbg:toolkit: UW-GAC Ancestry and Relatedness
