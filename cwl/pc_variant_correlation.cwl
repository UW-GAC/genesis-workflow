cwlVersion: v1.2
class: Workflow
label: PC-variant correlation
$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: ScatterFeatureRequirement
- class: InlineJavascriptRequirement
- class: StepInputExpressionRequirement

inputs:
- id: out_prefix
  label: Output prefix
  doc: Prefix for output files.
  type: string
  sbg:x: -15
  sbg:y: 210
- id: gds_file_full
  label: Full GDS Files
  doc: GDS files (one per chromosome) used to calculate PC-variant correlations.
  type: File[]
  sbg:fileTypes: GDS
  sbg:x: 4
  sbg:y: 343
- id: variant_include_file
  label: Variant include file
  doc: |-
    RData files (one per chromosome) with vector of variant.id to include. These variants will be added to the set of randomly selected variants. It is recommended to provide the set of pruned variants used for PCA.
  type: File[]
  sbg:fileTypes: RDATA
  sbg:x: 5
  sbg:y: -62
- id: pca_file
  label: PCA file
  doc: RData file with PCA results for unrelated samples
  type: File
  sbg:fileTypes: RDATA
  sbg:x: -3
  sbg:y: 78
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
  doc: Number of PCs to plot.
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
  doc: Thin points in PC-variant correlation plots
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
- id: pc_correlation_plots
  label: PC-variant correlation plots
  doc: PC-variant correlation plots
  type: File[]
  outputSource:
  - pca_corr_plots/pca_corr_plots
  sbg:fileTypes: PNG
  sbg:x: 858
  sbg:y: 89
- id: pca_corr_gds
  label: PC-variant correlation
  doc: GDS file with PC-variant correlation results
  type: File[]
  outputSource:
  - pca_corr/pca_corr_gds
  sbg:fileTypes: GDS
  sbg:x: 767
  sbg:y: 265

steps:
- id: pca_corr_vars
  label: pca_corr_vars
  in:
  - id: gds_file
    source: gds_file_full
  - id: variant_include_file
    source: variant_include_file
  - id: pca_file
    source: pca_file
  - id: out_file
    source: out_prefix
    valueFrom: |-
      ${
        return self + '_' + inputs.gds_file.nameroot + '_pc_corr_variants.RData'
      }
  - id: n_corr_vars
    source: n_corr_vars
  scatter:
  - gds_file
  - variant_include_file
  scatterMethod: dotproduct
  run: tools/pca_corr_vars.cwl
  out:
  - id: pca_corr_vars
  sbg:x: 224
  sbg:y: 39
- id: pca_corr
  label: pca_corr
  in:
  - id: gds_file
    source: gds_file_full
  - id: variant_include_file
    source: pca_corr_vars/pca_corr_vars
  - id: pca_file
    source: pca_file
  - id: n_pcs_corr
    source: n_pcs_corr
  - id: out_file
    source: out_prefix
    valueFrom: |-
      ${
        return self + '_' + inputs.gds_file.nameroot + '_pc_corr.gds'
      }
  - id: cpu
    source: cpu
  scatter:
  - gds_file
  - variant_include_file
  scatterMethod: dotproduct
  run: tools/pca_corr.cwl
  out:
  - id: pca_corr_gds
  sbg:x: 435
  sbg:y: 151
- id: pca_corr_plots
  label: pca_corr_plots
  in:
  - id: corr_file
    source:
    - pca_corr/pca_corr_gds
  - id: n_pcs_plot
    source: n_pcs_plot
  - id: n_perpage
    source: n_perpage
  - id: out_prefix
    source: out_prefix
    valueFrom: |-
      ${
        return self + '_pc_corr'
      }
  run: tools/pca_corr_plots.cwl
  out:
  - id: pca_corr_plots
  sbg:x: 633
  sbg:y: 29
