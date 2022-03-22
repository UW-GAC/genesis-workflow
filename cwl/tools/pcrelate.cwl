cwlVersion: v1.2
class: CommandLineTool
label: pcrelate
$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: ShellCommandRequirement
- class: DockerRequirement
  dockerPull: uwgac/genesis-workflow:3.0.0
- class: InlineJavascriptRequirement

inputs:
- id: gds_file
  label: GDS File
  doc: Input GDS file. It is recommended to use an LD pruned file with all chromosomes.
  type: File
  inputBinding:
    prefix: --gds_file
    position: 1
    shellQuote: false
  sbg:category: Input Files
  sbg:fileTypes: GDS
- id: pca_file
  label: PCA file
  doc: |-
    RData file with PCA results from PC-AiR workflow; used to adjust for population structure.
  type: File
  inputBinding:
    prefix: --pca_file
    position: 2
    shellQuote: false
  sbg:category: Input Files
  sbg:fileTypes: RDATA
- id: beta_file
  label: ISAF beta values
  doc: RData file with output from pcrelate_beta tool.
  type: File
  inputBinding:
    prefix: --beta_file
    position: 4
    shellQuote: false
  sbg:category: Input Files
  sbg:fileTypes: RDATA
- id: out_prefix
  label: Output prefix
  doc: Prefix for output files.
  type: string
  inputBinding:
    prefix: --out_prefix
    position: 5
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: pcrelate
- id: sample_include_file
  label: Sample Include file
  doc: |-
    RData file with vector of sample.id to include. If not provided, all samples in the GDS file are included.
  type: File?
  inputBinding:
    prefix: --sample_include_file
    position: 10
    shellQuote: false
  sbg:category: Input Files
  sbg:fileTypes: RDATA
- id: variant_include_file
  label: Variant include file
  doc: |-
    RData file with vector of variant.id to include. If not provided, all variants in the GDS file are included.
  type: File?
  inputBinding:
    prefix: --variant_include_file
    position: 11
    shellQuote: false
  sbg:category: Input Files
- id: n_pcs
  label: Number of PCs
  doc: Number of PCs to use in adjusting for ancestry.
  type: int?
  inputBinding:
    prefix: --n_pcs
    position: 6
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: '3'
- id: ibd_probs
  label: Return IBD probabilities?
  doc: |-
    Set this to FALSE to skip computing pairwise IBD probabilities (k0, k1, k2). If FALSE, the plottng step is also skipped, as it requires values for k0.
  type:
  - 'null'
  - name: ibd_probs
    type: enum
    symbols:
    - "TRUE"
    - "FALSE"
  default: "TRUE"
  inputBinding:
    prefix: --ibd_probs
    position: 7
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: 'true'
- id: variant_block_size
  label: Variant block size
  doc: Number of variants to read in a single block.
  type: int?
  inputBinding:
    prefix: --variant_block_size
    position: 21
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: '1024'
- id: n_sample_blocks
  label: Number of sample blocks
  doc: |-
    Number of blocks to divide samples into for parallel computation. Adjust depending on computer memory and number of samples in the analysis.
  type: int?
  inputBinding:
    prefix: --n_sample_blocks
    position: 30
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: '1'
- id: sample_block_1
  label: Index of first sample block
  doc: |-
    If number of sample blocks is > 1, run on this combination of sample blocks.
  type: int?
  inputBinding:
    prefix: --i
    position: 31
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: '1'
- id: sample_block_2
  label: Index of second sample block
  doc: |-
    If number of sample blocks is > 1, run on this combination of sample blocks.
  type: int?
  inputBinding:
    prefix: --j
    position: 32
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: '1'

outputs:
- id: pcrelate
  label: PC-Relate results
  doc: RData files with PC-Relate results for each sample block.
  type: File[]
  outputBinding:
    glob: '*.RData'
  sbg:fileTypes: RDATA
stdout: job.out.log
stderr: job.err.log

baseCommand:
- R
- -q 
- --vanilla
- --args
arguments:
- prefix: <
  position: 100
  valueFrom: /usr/local/genesis-workflow/R/pcrelate.R
  shellQuote: false

hints:
- class: sbg:SaveLogs
  value: '*.params'
- class: sbg:SaveLogs
  value: '*.log'
