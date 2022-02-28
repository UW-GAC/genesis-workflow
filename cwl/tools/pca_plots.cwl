cwlVersion: v1.2
class: CommandLineTool
label: pca_plots
$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: ShellCommandRequirement
- class: DockerRequirement
  dockerPull: uwgac/genesis-workflow:3.0.0
- class: InlineJavascriptRequirement

inputs:
- id: pca_file
  label: PCA File
  doc: RData file containing pcair object (output by pca_byrel tool)
  type: File
  inputBinding:
    prefix: --pca_file
    position: 1
    shellQuote: false
  sbg:category: Input Files
  sbg:fileTypes: RDATA
- id: phenotype_file
  label: Phenotype file
  doc: |-
    RData file with data.frame or AnnotatedDataFrame of phenotypes. Used for color-coding PCA plots by group.
  type: File?
  inputBinding:
    prefix: --phenotype_file
    position: 20
    shellQuote: false
  sbg:category: Input Files
  sbg:fileTypes: RDATA
- id: n_pairs
  label: Number of PCs
  doc: Number of PCs to include in the pairs plot.
  type: int?
  inputBinding:
    prefix: --n_pairs
    position: 2
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: '6'
- id: group
  label: Group
  doc: |-
    Name of column in phenotype_file containing group variable for color-coding plots.
  type: string?
  inputBinding:
    prefix: --group
    position: 21
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: NA
- id: out_prefix
  label: Output prefix
  doc: Prefix for output files.
  type: string?
  inputBinding:
    prefix: --out_prefix
    position: 5
    shellQuote: false
  sbg:category: Input Options

outputs:
- id: pca_plots
  label: PC plots
  doc: PC plots
  type: File[]
  outputBinding:
    glob: '*.p??'
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
  valueFrom: /usr/local/genesis-workflow/R/pca_plots.R
  shellQuote: false

hints:
- class: sbg:SaveLogs
  value: '*.params'
- class: sbg:SaveLogs
  value: '*.log'
