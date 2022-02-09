cwlVersion: v1.2
class: Workflow
label: KING IBDseg
doc: |-
  This workflow uses the KING --ibdseg method to estimate kinship coefficients, and returns 
  results for pairs of related samples. These kinship estimates can be used as measures of 
  kinship in PC-AiR.

  Recommended usage is to provide the pruned GDS file from the LD pruning workflow as input.
  Additional variant filtering may be done by providing a file of variant.id to include.
  Note that the variant ids in the LD pruned GDS file may be different than the ids in the
  per-chromosome GDS files used as input to the LD pruning workflow.

  The workflow first converts the GDS file to PLINK BED format, followed by formatting the BED
  file using PLINK. Both these steps are required to create an input file accepted by KING.
  
  KING returns a file with pairwise relationships listed in rows with a '.seg' extension.
  A subsequent workflow step creates a block-diagonal Matrix object in R, with values for
  pairs outside of family blocks set to zero. The threshold for sparsity may be set by the user.
  This format represents a huge savings in storage and computation time for subsequent analyses
  over a dense matrix.

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
  sbg:x: -527
  sbg:y: 339
- id: sample_include_file
  label: Sample Include file
  doc: |-
    RData file with vector of sample.id to include. If not provided, all samples in the GDS file are included.
  type: File
  sbg:fileTypes: RDATA
  sbg:x: -539
  sbg:y: 150
- id: variant_include_file
  label: Variant Include file
  doc: |-
    RData file with vector of variant.id to use for kinship estimation. If not provided, all variants in the GDS file are included.
  type: File?
  sbg:fileTypes: RDATA
  sbg:x: -554
  sbg:y: -59
- id: out_prefix
  label: Output prefix
  doc: Prefix for output files.
  type: string
  sbg:x: -429
  sbg:y: -223
- id: phenotype_file
  label: Phenotype File
  doc: |-
    RData file with data.frame or AnnotatedDataFrame of phenotypes. Used for plotting kinship estimates separately by group.
  type: File?
  sbg:fileTypes: RDATA
  sbg:x: 128
  sbg:y: -225
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
- id: sparse_threshold
  label: Sparse threshold
  doc: |-
    Threshold for making the output kinship matrix sparse. A block diagonal matrix will be created such that any pair of samples with a kinship estimate greater than the threshold is in the same block; all pairwise estimates within a block are kept, and pairwise estimates between blocks are set to 0.
  type: float?
  sbg:exposed: true
  sbg:toolDefaultValue: 2^(-11/2) (~0.022, 4th degree)
- id: cpu
  label: Number of CPUs
  doc: Number of CPUs to use.
  type: int?
  sbg:exposed: true
  sbg:toolDefaultValue: '4'

outputs:
- id: king_ibdseg_matrix
  label: Kinship matrix
  doc: |-
    A block-diagonal matrix of pairwise kinship estimates. Samples are clustered into blocks of relatives based on `sparse_threshold`; all kinship estimates within a block are kept, and kinship estimates between blocks are set to 0. When `sparse_threshold` is 0, all kinship estimates are included in the output matrix.
  type: File
  outputSource:
  - king_to_matrix/king_matrix
  sbg:fileTypes: RDATA
  sbg:x: 698
  sbg:y: 229
- id: king_ibdseg_plots
  label: Kinship plots
  doc: |-
    Hexbin plots of estimated kinship coefficients vs. IBS0. If "group" is provided, additional plots will be generated within each group and across groups.
  type: File[]
  outputSource:
  - kinship_plots/kinship_plots
  sbg:fileTypes: PDF
  sbg:x: 681
  sbg:y: -158
- id: king_ibdseg_output
  label: KING ibdseg output
  doc: |-
    Text file with pairwise kinship estimates for all sample pairs with any detected IBD segments.
  type: File
  secondaryFiles:
  - pattern: ^.segments.gz
    required: false
  - pattern: ^allsegs.txt
    required: false
  outputSource:
  - king_ibdseg/king_ibdseg_output
  sbg:fileTypes: SEG
  sbg:x: 684
  sbg:y: 10

steps:
- id: gds2bed
  label: gds2bed
  in:
  - id: gds_file
    source: gds_file
  - id: sample_include_file
    source: sample_include_file
  - id: variant_include_file
    source: variant_include_file
  run: tools/gds2bed.cwl
  out:
  - id: bed_file
  sbg:x: -377
  sbg:y: -24
- id: plink_make_bed
  label: plink_make-bed
  in:
  - id: bed_file
    source: gds2bed/bed_file
  run: tools/plink_make_bed.cwl
  out:
  - id: bed_file_recode
  sbg:x: -140
  sbg:y: -20
- id: king_ibdseg
  label: king_ibdseg
  in:
  - id: bed_file
    source: plink_make_bed/bed_file_recode
  - id: cpu
    source: cpu
  - id: out_prefix
    valueFrom: |-
      ${
        return self + '_king_ibdseg'
      }
    source: out_prefix
  run: tools/king_ibdseg.cwl
  out:
  - id: king_ibdseg_output
  sbg:x: 105
  sbg:y: -15
- id: king_to_matrix
  label: king_to_matrix
  in:
  - id: king_file
    source: king_ibdseg/king_ibdseg_output
  - id: sample_include_file
    source: sample_include_file
  - id: sparse_threshold
    default: 0.01104854
    source: sparse_threshold
  - id: out_file
    valueFrom: |-
      ${
        return self + '_king_ibdseg_Matrix.RData'
      }
    source: out_prefix
  - id: kinship_method
    default: king_ibdseg
  run: tools/king_to_matrix.cwl
  out:
  - id: king_matrix
  sbg:x: 276
  sbg:y: 91
- id: kinship_plots
  label: kinship_plots
  in:
  - id: kinship_file
    source: king_ibdseg/king_ibdseg_output
  - id: kinship_method
    default: king_ibdseg
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
        return self + '_king_ibdseg'
      }
    source: out_prefix
  run: tools/kinship_plots.cwl
  out:
  - id: kinship_plots
  sbg:x: 337
  sbg:y: -168
sbg:categories:
- GWAS
- Ancestry and Relatedness
sbg:toolkit: UW-GAC Ancestry and Relatedness
