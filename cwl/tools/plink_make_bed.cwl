cwlVersion: v1.2
class: CommandLineTool
label: plink_make-bed
$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: ShellCommandRequirement
- class: DockerRequirement
  dockerPull: uwgac/genesis-workflow:3.0.0
- class: InlineJavascriptRequirement

inputs:
- id: bed_file
  label: BED File
  doc: BED file to recode. Prefix will be used for constructing output filename.
  type: File
  secondaryFiles:
  - pattern: ^.fam
    required: true
  - pattern: ^.bim
    required: true
  sbg:category: Input Files
  sbg:fileTypes: BED

outputs:
- id: bed_file_recode
  label: Processed BED
  doc: BED file processed by plink
  type: File
  secondaryFiles:
  - pattern: ^.bim
    required: true
  - pattern: ^.fam
    required: true
  outputBinding:
    glob: '*_recode.bed'
  sbg:fileTypes: BED
stdout: job.out.log
stderr: job.err.log

baseCommand:
- plink 
- --make-bed
arguments:
- prefix: --bfile
  position: 1
  valueFrom: ${ return inputs.bed_file.path.split('.').slice(0,-1).join('.') }
  shellQuote: false
- prefix: --out
  position: 2
  valueFrom: ${ return inputs.bed_file.nameroot + "_recode" }
  shellQuote: false

hints:
- class: sbg:SaveLogs
  value: '*.log'
