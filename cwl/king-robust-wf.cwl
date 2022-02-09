cwlVersion: v1.2
class: Workflow
label: KING robust
doc: |-
  This workflow uses the KING-robust method to estimate kinship coefficients, and returns results 
  for all pairs of samples. Due to the negative bias of these kinship estimates for samples of 
  different ancestry, they can be used as a measure of ancestry divergence in PC-AiR.

  Recommended usage is to provide the pruned GDS file from the LD pruning workflow as input.
  Additional variant filtering may be done by providing a file of variant.id to include.
  Note that the variant ids in the LD pruned GDS file may be different than the ids in the
  per-chromosome GDS files used as input to the LD pruning workflow.

  This workflow uses the implementation of the KING robust algorithm in the SNPRelate R package.
  The output is a GDS file with a dense NxN matrix of pairwise kinship coefficients.

  The final output of the workflow is a plot of kinship estimates vs IBS0, which gives
  on overview of the amount of relatedness in the dataset. Only pairs above the specified
  kinship plot threshold are displayed. Since many analyses include multiple
  cohorts, a phenotype file may be provided to identify cohorts or groups for plotting separately.
  The phenotype file should be in RDATA format and contain a data.frame or AnnotatedDataFrame. 
  Columns must include sample.id and a group variable, with the name of
  the group column specified as a separate argument. If these inputs are provided, additional
  plots will be created showing kinship separately within each group and across groups.
$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: InlineJavascriptRequirement
- class: StepInputExpressionRequirement

inputs:
- id: gds_file
  label: GDS file
  doc: Input GDS file. It is recommended to use an LD pruned file with all chromosomes.
  type: File
  sbg:fileTypes: GDS
  sbg:x: -289
  sbg:y: 70
- id: sample_include_file
  label: Sample Include file
  doc: |-
    RData file with vector of sample.id to include. If not provided, all samples in the GDS file are included.
  type: File?
  sbg:fileTypes: RDATA
  sbg:x: -353
  sbg:y: -120
- id: variant_include_file
  label: Variant Include file
  doc: |-
    RData file with vector of variant.id to use for kinship estimation. If not provided, all variants in the GDS file are included.
  type: File?
  sbg:fileTypes: RDATA
  sbg:x: -294
  sbg:y: -242
- id: out_prefix
  label: Output prefix
  doc: Prefix for output files.
  type: string?
  sbg:x: -397
  sbg:y: 1
- id: phenotype_file
  label: Phenotype File
  doc: |-
    RData file with data.frame or AnnotatedDataFrame of phenotypes. Used for plotting kinship estimates separately by group.
  type: File?
  sbg:fileTypes: RDATA
  sbg:x: -117
  sbg:y: 117
- id: kinship_plot_threshold
  label: Kinship plotting threshold
  doc: Minimum kinship for a pair to be included in the plot.
  type: float?
  sbg:exposed: true
  sbg:toolDefaultValue: 2^(-9/2) (third-degree relatives and closer)
- id: group
  label: Group column name
  doc: |-
    Name of column in phenotype_file containing group variable (e.g., study) for plotting.
  type: string?
  sbg:exposed: true

outputs:
- id: king_robust_output
  label: KING robust output
  doc: GDS file with matrix of pairwise kinship estimates.
  type: File
  outputSource:
  - king_robust/king_robust_output
  sbg:fileTypes: GDS
  sbg:x: 98
  sbg:y: -235
- id: king_robust_plots
  label: Kinship plots
  doc: |-
    Hexbin plots of estimated kinship coefficients vs. IBS0. If "group" is provided, additional plots will be generated within each group and across groups.
  type: File[]
  outputSource:
  - kinship_plots/kinship_plots
  sbg:fileTypes: PDF
  sbg:x: 312
  sbg:y: -108

steps:
- id: king_robust
  label: king_robust
  in:
  - id: gds_file
    source: gds_file
  - id: out_file
    valueFrom: |-
      ${
        return self + '_king_robust.gds'
      }
    source: out_prefix
  - id: sample_include_file
    source: sample_include_file
  - id: variant_include_file
    source: variant_include_file
  run: tools/king_robust.cwl
  out:
  - id: king_robust_output
  sbg:x: -168
  sbg:y: -76
- id: kinship_plots
  label: kinship_plots
  in:
  - id: kinship_file
    source: king_robust/king_robust_output
  - id: kinship_method
    default: king_robust
  - id: kinship_plot_threshold
    source: kinship_plot_threshold
  - id: phenotype_file
    source: phenotype_file
  - id: group
    source: group
  - id: sample_include_file
    source: sample_include_file
  - id: out_prefix
    valueFrom: |-
      ${ 
        return self + '_king_robust'
      }
    source: out_prefix
  run: tools/kinship_plots.cwl
  out:
  - id: kinship_plots
  sbg:x: 30
  sbg:y: -9
sbg:categories:
- GWAS
- Ancestry and relatedness
sbg:toolkit: UW-GAC Ancestry and Relatedness
