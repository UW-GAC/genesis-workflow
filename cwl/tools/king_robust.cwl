cwlVersion: v1.2
class: CommandLineTool
label: king_robust
$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: ShellCommandRequirement
- class: ResourceRequirement
  coresMin: |-
    ${
        if (inputs.cpu) {
            return inputs.cpu
        } else {
            return 4
        }
        
    }
- class: DockerRequirement
  dockerPull: uwgac/genesis-workflow:3.0.0
- class: InlineJavascriptRequirement

inputs:
- id: gds_file
  label: GDS file
  doc: Input GDS file.
  type: File
  inputBinding:
    prefix: --gds_file
    position: 1
    shellQuote: false
  sbg:category: Input Files
  sbg:fileTypes: GDS
- id: out_file
  label: Output filename
  doc: Name for output file.
  type: string
  inputBinding:
    prefix: --out_file
    position: 2
    shellQuote: false
  sbg:category: Input Options
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
  label: Variant Include file
  doc: |-
    RData file with vector of variant.id to use for kinship estimation. If not provided, all variants in the GDS file are included.
  type: File?
  inputBinding:
    prefix: --variant_include_file
    position: 11
    shellQuote: false
  sbg:category: Input Files
  sbg:fileTypes: RDATA
- id: cpu
  label: Number of CPUs
  doc: Number of CPUs to use.
  type: int?
  default: 4
  inputBinding:
    prefix: --num_cores
    position: 20
    shellQuote: false
  sbg:category: Input Options

outputs:
- id: king_robust_output
  label: KING robust output
  doc: GDS file with matrix of pairwise kinship estimates.
  type: File
  outputBinding:
    glob: '*.gds'
  sbg:fileTypes: GDS
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
  valueFrom: /usr/local/genesis-workflow/R/ibd_king.R
  shellQuote: false

hints:
- class: sbg:SaveLogs
  value: '*.params'
- class: sbg:SaveLogs
  value: '*.log'
