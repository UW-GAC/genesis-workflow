cwlVersion: v1.2
class: CommandLineTool
label: check_merged_gds
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
  doc: Base reference file for comparison.
  type: File
  inputBinding:
    prefix: --gds_file
    position: 1
    shellQuote: false
  sbg:category: Input Files
  sbg:fileTypes: GDS
- id: merged_gds_file
  label: Merged GDS file
  doc: |-
    Output of merge_gds script. This file is being checked against starting gds file.
  type: File
  inputBinding:
    prefix: --merged_gds_file
    position: 2
    shellQuote: false
  sbg:category: Input Files
  sbg:fileTypes: GDS

outputs: []
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
  valueFrom: /usr/local/genesis-workflow/R/check_merged_gds.R
  shellQuote: false

hints:
- class: sbg:SaveLogs
  value: "*.params"
- class: sbg:SaveLogs
  value: "*.log"
