cwlVersion: v1.2
class: CommandLineTool
label: pcrelate_beta
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
  sbg:fileTypes: RDATA
- id: out_file
  label: Output filename
  doc: Name for output file.
  type: string
  inputBinding:
    prefix: --out_file
    position: 3
    shellQuote: false
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
  sbg:fileTypes: RDATA
- id: n_pcs
  label: Number of PCs
  doc: Number of PCs (Principal Components) to use in adjusting for ancestry.
  type: int?
  inputBinding:
    prefix: --n_pcs
    position: 4
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: '3'
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

outputs:
- id: beta
  label: ISAF beta values
  doc: RData file with ISAF beta values
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
  valueFrom: /usr/local/genesis-workflow/R/pcrelate_beta.R
  shellQuote: false

hints:
- class: sbg:SaveLogs
  value: '*.params'
- class: sbg:SaveLogs
  value: '*.log'
