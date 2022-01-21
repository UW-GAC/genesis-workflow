cwlVersion: v1.2
class: CommandLineTool
label: subset_gds
$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: ShellCommandRequirement
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
  label: Sample include file
  doc: |-
    RData file with vector of sample.id to include. All samples in the GDS file are included when not provided.
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
    RData file with vector of variant.id to include. All variants in the GDS files are used when not provided.
  type: File
  inputBinding:
    prefix: --variant_include_file
    position: 11
    shellQuote: false
  sbg:category: Input Files
  sbg:fileTypes: RDATA

outputs:
- id: output
  label: Subset file
  doc: GDS file with subset of variants from original file
  type: File?
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
  valueFrom: /usr/local/genesis-workflow/R/subset_gds.R
  shellQuote: false

hints:
- class: sbg:SaveLogs
  value: "*.params"
- class: sbg:SaveLogs
  value: "*.log"
