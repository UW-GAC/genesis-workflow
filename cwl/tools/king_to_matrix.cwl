cwlVersion: v1.2
class: CommandLineTool
label: king_to_matrix
$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: ShellCommandRequirement
- class: DockerRequirement
  dockerPull: uwgac/genesis-workflow:3.0.0
- class: InlineJavascriptRequirement

inputs:
- id: king_file
  label: KING File
  doc: Output of KING software.
  type: File
  inputBinding:
    prefix: --king_file
    position: 1
    shellQuote: false
  sbg:category: Input Files
  sbg:fileTypes: SEG, KIN
- id: out_file
  label: Output filename
  doc: Name for output file.
  type: string
  inputBinding:
    prefix: --out_file
    position: 2
    shellQuote: false
  sbg:category: Input Options
- id: kinship_method
  label: Kinship method
  doc: KING algorithm used.
  type:
    name: kinship_method
    type: enum
    symbols:
    - king_ibdseg
    - king_robust
  inputBinding:
    prefix: --kinship_method
    position: 3
    shellQuote: false
  sbg:category: Input Options
- id: sparse_threshold
  label: Sparse threshold
  doc: |-
    Threshold for making the output kinship matrix sparse. A block diagonal matrix will be created such that any pair of samples with a kinship estimate greater than the threshold is in the same block; all pairwise estimates within a block are kept, and pairwise estimates between blocks are set to 0.
  type: float?
  default: 0.02209709
  inputBinding:
    prefix: --sparse_threshold
    position: 4
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: 2^(-11/2) (~0.022, 4th degree)
- id: sample_include_file
  label: Sample Include file
  doc: |-
    RData file with vector of sample.id to include. If not provided, all samples are included.
  type: File?
  inputBinding:
    prefix: --sample_include_file
    position: 10
    shellQuote: false
  sbg:category: Input Files
  sbg:fileTypes: RDATA

outputs:
- id: king_matrix
  label: Kinship matrix
  doc: |-
    A block-diagonal matrix of pairwise kinship estimates. Samples are clustered into blocks of relatives based on `sparse_threshold`; all kinship estimates within a block are kept, and kinship estimates between blocks are set to 0.
  type: File
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
  valueFrom: /usr/local/genesis-workflow/R/king_to_matrix.R
  shellQuote: false

hints:
- class: sbg:SaveLogs
  value: '*.params'
- class: sbg:SaveLogs
  value: '*.log'
