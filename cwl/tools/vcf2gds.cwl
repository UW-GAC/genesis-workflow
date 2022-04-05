cwlVersion: v1.2
class: CommandLineTool
label: vcf2gds
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
- id: vcf_file
  label: VCF file
  doc: Input VCF file.
  type: File
  inputBinding:
    prefix: --vcf_file
    position: 1
    shellQuote: false
  sbg:category: Input Files
  sbg:fileTypes: VCF, VCF.GZ, BCF
- id: gds_file
  label: GDS File
  doc: Output GDS file. If not provided, the base name will be the same as the VCF file.
  type: string?
  inputBinding:
    prefix: --gds_file
    position: 2
    shellQuote: false
  sbg:category: Input Options
- id: format
  label: Format
  doc: VCF Format fields to keep in GDS file.
  type: string[]?
  inputBinding:
    prefix: --format
    position: 3
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: GT
- id: cpu
  label: cpu
  doc: Number of CPUs to use.
  type: int?
  default: 4
  inputBinding:
    prefix: --num_cores
    position: 20
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: '4'

outputs:
- id: gds_output
  label: GDS Output File
  doc: GDS Output File.
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
  valueFrom: /usr/local/genesis-workflow/R/vcf2gds.R
  shellQuote: false

hints:
- class: sbg:SaveLogs
  value: '*.params'
- class: sbg:SaveLogs
  value: '*.log'
