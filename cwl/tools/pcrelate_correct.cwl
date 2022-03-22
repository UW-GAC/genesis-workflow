cwlVersion: v1.2
class: CommandLineTool
label: pcrelate_correct
$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: ShellCommandRequirement
- class: DockerRequirement
  dockerPull: uwgac/genesis-workflow:3.0.0
- class: InlineJavascriptRequirement

inputs:
- id: pcrelate_block_files
  label: PCRelate files for all sample blocks
  doc: PCRelate files for all sample blocks
  type: File[]
  inputBinding:
    prefix: --pcrelate_prefix
    position: 1
    valueFrom: |-
      ${
        return self[0].path.split("_block_")[0]
      }
  sbg:category: Input Files
  sbg:fileTypes: RDATA
- id: out_prefix
  label: Output prefix
  doc: Prefix for output files.
  type: string
  inputBinding:
    prefix: --out_prefix
    position: 2
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: pcrelate
- id: sparse_threshold
  label: Sparse threshold
  doc: |-
    Threshold for making the output kinship matrix sparse. A block diagonal matrix will be created such that any pair of samples with a kinship estimate greater than the threshold is in the same block; all pairwise estimates within a block are kept, and pairwise estimates between blocks are set to 0.
  type: float?
  inputBinding:
    prefix: --sparse_threshold
    position: 3
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: 2^(-11/2) (~0.022, 4th degree)
- id: n_sample_blocks
  label: Number of sample blocks
  doc: |-
    Number of blocks to divide samples into for parallel computation. Adjust depending on computer memory and number of samples in the analysis.
  type: int?
  inputBinding:
    prefix: --n_sample_blocks
    position: 4
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: '1'

outputs:
- id: pcrelate_output
  label: PC-Relate output file
  doc: PC-Relate output file with all samples
  type: File
  outputBinding:
    glob: |-
      ${ 
        return inputs.out_prefix + ".RData"
      }
  sbg:fileTypes: RDATA
- id: pcrelate_matrix
  label: Kinship matrix
  doc: |-
    A block diagonal matrix of pairwise kinship estimates with sparsity set by sparse_threshold. Samples are clustered into blocks of relatives based on `sparse_threshold`; all kinship estimates within a block are kept, and kinship estimates between blocks are set to 0. When `sparse_threshold` is 0, this is a dense matrix with all pairwise kinship estimates.
  type: File
  outputBinding:
    glob: |-
      ${ 
        return inputs.out_prefix + "_Matrix.RData"
      }
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
  valueFrom: /usr/local/genesis-workflow/R/pcrelate_correct.R
  shellQuote: false

hints:
- class: sbg:SaveLogs
  value: '*.params'
- class: sbg:SaveLogs
  value: '*.log'
