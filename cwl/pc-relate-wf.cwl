cwlVersion: v1.2
class: Workflow
label: PC-Relate
doc: |-
  This workflow estimates kinship and IBD sharing probabilities between all pairs of samples using the PC-Relate method, which accounts for population structure by conditioning on ancestry PCs.
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
  sbg:exposed: true
- id: gds_file
  label: GDS File
  doc: Input GDS file. It is recommended to use an LD pruned file with all chromosomes.
  type: File
  sbg:fileTypes: GDS
  sbg:x: -205
  sbg:y: 181
- id: pca_file
  label: PCA file
  doc: |-
    RData file with PCA results from PC-AiR workflow; used to adjust for population structure.
  type: File
  sbg:fileTypes: RDATA
  sbg:x: -189
  sbg:y: 53
- id: sample_include_file
  label: Sample Include file
  doc: |-
    RData file with vector of sample.id to include. If not provided, all samples in the GDS file are included.
  type: File?
  sbg:fileTypes: RDATA
  sbg:x: -175
  sbg:y: -73
- id: variant_include_file
  label: Variant include file
  doc: |-
    RData file with vector of variant.id to include. If not provided, all variants in the GDS file are included.
  type: File?
  sbg:fileTypes: RDATA
  sbg:x: -169
  sbg:y: -227
- id: phenotype_file
  label: Phenotype File
  doc: |-
    RData file with data.frame or AnnotatedDataFrame of phenotypes. Used for plotting kinship estimates separately by group.
  type: File?
  sbg:fileTypes: RDATA
  sbg:x: 645
  sbg:y: 170
- id: n_pcs
  label: Number of PCs
  doc: |-
    Number of PCs (Principal Components) in `pca_file` to use in adjusting for ancestry.
  type: int?
  sbg:toolDefaultValue: '3'
  sbg:exposed: true
- id: sparse_threshold
  label: Sparse threshold
  doc: |-
    Threshold for making the output kinship matrix sparse. A block diagonal matrix will be created such that any pair of samples with a kinship estimate greater than the threshold is in the same block; all pairwise estimates within a block are kept, and pairwise estimates between blocks are set to 0.
  type: float?
  sbg:exposed: true
  sbg:toolDefaultValue: 2^(-11/2) (~0.022, 4th degree)
- id: ibd_probs
  label: Return IBD probabilities?
  doc: |-
    Set this to FALSE to skip computing pairwise IBD probabilities (k0, k1, k2). If FALSE, the plotting step is also skipped, as it requires values for k0.
  type: boolean?
  default: true
  sbg:toolDefaultValue: 'true'
  sbg:exposed: true
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
- id: variant_block_size
  label: Variant block size
  doc: Number of variants to read in a single block.
  type: int?
  sbg:toolDefaultValue: '1024'
  sbg:exposed: true
- id: n_sample_blocks
  label: Number of sample blocks
  doc: |-
    Number of blocks to divide samples into for parallel computation. Adjust depending on computer memory and number of samples in the analysis.
  type: int?
  sbg:toolDefaultValue: '1'
  sbg:exposed: true

outputs:
- id: pcrelate_output
  label: PC-Relate output file
  doc: PC-Relate output file with all samples
  type: File
  outputSource:
  - pcrelate_correct/pcrelate_output
  sbg:fileTypes: RDATA
  sbg:x: 931
  sbg:y: -263
- id: pcrelate_matrix
  label: Kinship matrix
  doc: |-
    A block diagonal matrix of pairwise kinship estimates with sparsity set by sparse_threshold. Samples are clustered into blocks of relatives based on `sparse_threshold`; all kinship estimates within a block are kept, and kinship estimates between blocks are set to 0. When `sparse_threshold` is 0, this is a dense matrix with all pairwise kinship estimates.
  type: File
  outputSource:
  - pcrelate_correct/pcrelate_matrix
  sbg:fileTypes: RDATA
  sbg:x: 927
  sbg:y: -108
- id: pcrelate_plots
  label: Kinship plots
  doc: |-
    Hexbin plots of estimated kinship coefficients vs. IBS0. If "group" is provided, additional plots will be generated within each group and across groups.
  type: File[]?
  outputSource:
  - kinship_plots/kinship_plots
  sbg:fileTypes: PDF
  sbg:x: 1051
  sbg:y: 166

steps:
- id: pcrelate_beta
  label: pcrelate_beta
  in:
  - id: gds_file
    source: gds_file
  - id: pca_file
    source: pca_file
  - id: n_pcs
    source: n_pcs
  - id: out_file
    source: out_prefix
    valueFrom: |-
     ${
       return self + "_pcrelate_beta.RData"
     }
  - id: sample_include_file
    source: sample_include_file
  - id: variant_include_file
    source: variant_include_file
  - id: variant_block_size
    source: variant_block_size
  run: tools/pcrelate_beta.cwl
  out:
  - id: beta
  sbg:x: 111
  sbg:y: 18
- id: sample_blocks
  label: sample blocks
  in:
  - id: n_sample_blocks
    source: n_sample_blocks
  run: tools/sample_blocks.cwl
  out:
  - id: sample_block_1
  - id: sample_block_2
  sbg:x: 195
  sbg:y: -186
- id: pcrelate
  label: pcrelate
  in:
  - id: gds_file
    source: gds_file
  - id: pca_file
    source: pca_file
  - id: beta_file
    source: pcrelate_beta/beta
  - id: n_pcs
    source: n_pcs
  - id: out_prefix
    source: out_prefix
  - id: variant_include_file
    source: variant_include_file
  - id: variant_block_size
    source: variant_block_size
  - id: sample_include_file
    source: sample_include_file
  - id: n_sample_blocks
    source: n_sample_blocks
  - id: ibd_probs
    valueFrom: |-
      ${
        if (self) {
          return "TRUE"
        } else {
          return "FALSE"
        }
      }
    source: ibd_probs
  - id: sample_block_1
    source: sample_blocks/sample_block_1
  - id: sample_block_2
    source: sample_blocks/sample_block_2
  scatter:
  - sample_block_1
  - sample_block_2
  scatterMethod: dotproduct
  run: tools/pcrelate.cwl
  out:
  - id: pcrelate
  sbg:x: 407
  sbg:y: 4
- id: pcrelate_correct
  label: pcrelate_correct
  in:
  - id: n_sample_blocks
    source: n_sample_blocks
  - id: pcrelate_block_files
    source:
    - pcrelate/pcrelate
  - id: out_prefix
    valueFrom: |-
      ${ 
        return self + "_pcrelate"
      }
    source: out_prefix
  - id: sparse_threshold
    source: sparse_threshold
  run: tools/pcrelate_correct.cwl
  out:
  - id: pcrelate_output
  - id: pcrelate_matrix
  sbg:x: 610
  sbg:y: -144
- id: kinship_plots
  label: kinship_plots
  in:
  - id: kinship_file
    source: pcrelate_correct/pcrelate_output
  - id: kinship_method
    default: pcrelate
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
        return self + "_pcrelate"
      }
    source: out_prefix
  - id: run_plots
    source: ibd_probs
  run: tools/kinship_plots.cwl
  when: $(inputs.run_plots)
  out:
  - id: kinship_plots
  sbg:x: 801
  sbg:y: 40
sbg:categories:
- GWAS
- Ancestry and Relatedness
sbg:toolkit: UW-GAC Ancestry and Relatedness
