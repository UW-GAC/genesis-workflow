cwlVersion: v1.2
class: CommandLineTool
label: pca_corr_plots
$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: ShellCommandRequirement
- class: DockerRequirement
  dockerPull: uwgac/genesis-workflow:3.0.0
- class: InlineJavascriptRequirement

inputs:
- id: corr_file
  label: PC correlation files
  doc: PC correlation files
  type: File[]
  inputBinding:
    prefix: --corr_file
    position: 1
    shellQuote: false
  sbg:category: Input File
  sbg:fileTypes: GDS
- id: n_pcs_plot
  label: Number of PCs to plot
  doc: Number of PCs to plot.
  type: int?
  inputBinding:
    prefix: --n_pcs
    position: 2
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: '20'
- id: n_perpage
  label: Number of plots per page
  doc: |-
    Number of PC-variant correlation plots to stack in a single page. The number of png files generated will be ceiling(n_pcs_plot/n_perpage).
  type: int?
  inputBinding:
    prefix: --n_perpage
    position: 3
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: '4'
- id: out_prefix
  label: Output prefix
  doc: Prefix for output files.
  type: string
  inputBinding:
    prefix: --out_prefix
    position: 5
    shellQuote: false
  sbg:category: Input Options
- id: thin_corr_plots
  label: Thin PC-variant correlation plots
  doc: Thin points in PC-variant correlation plots
  type:
  - 'null'
  - name: thin
    type: enum
    symbols:
    - "TRUE"
    - "FALSE"
  default: "TRUE"
  inputBinding:
    prefix: --thin
    position: 6
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: 'true'

outputs:
- id: pca_corr_plots
  label: PC-variant correlation plots
  doc: PC-variant correlation plots
  type: File[]
  outputBinding:
    glob: '*.png'
  sbg:fileTypes: PNG
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
  valueFrom: /usr/local/genesis-workflow/R/pca_corr_plots.R
  shellQuote: false

hints:
- class: sbg:SaveLogs
  value: '*.params'
- class: sbg:SaveLogs
  value: '*.log'
