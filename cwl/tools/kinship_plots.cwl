cwlVersion: v1.2
class: CommandLineTool
label: kinship_plots
$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: ShellCommandRequirement
- class: DockerRequirement
  dockerPull: uwgac/genesis-workflow:3.0.0
- class: InlineJavascriptRequirement

inputs:
- id: kinship_file
  label: Kinship File
  doc: Kinship file
  type: File
  inputBinding:
    prefix: --kinship_file
    position: 1
    shellQuote: false
  sbg:category: Input Files
  sbg:fileTypes: RDATA, SEG, KIN, GDS
- id: kinship_method
  label: Kinship method
  doc: Method used to generate kinship estimates.
  type:
    name: kinship_method
    type: enum
    symbols:
    - king_ibdseg
    - king_robust
    - pcrelate
  inputBinding:
    prefix: --kinship_method
    position: 3
    shellQuote: false
  sbg:category: Input Options
- id: kinship_plot_threshold
  label: Kinship plotting threshold
  doc: Minimum kinship for a pair to be included in the plot.
  type: float?
  inputBinding:
    prefix: --kinship_threshold
    position: 4
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: 2^(-9/2) (third-degree relatives and closer)
- id: out_prefix
  label: Output prefix
  doc: Prefix for output files.
  type: string
  inputBinding:
    prefix: --out_prefix
    position: 5
    shellQuote: false
  sbg:category: Input Options
- id: sample_include_file
  label: Sample Include File
  doc: RData file with vector of sample.id to include. If not provided, all samples are included.
  type: File?
  inputBinding:
    prefix: --sample_include_file
    position: 10
    shellQuote: false
  sbg:category: Input Options
  sbg:fileTypes: RDATA
- id: phenotype_file
  label: Phenotype File
  doc: |-
    RData file with data.frame or AnnotatedDataFrame of phenotypes. Used for plotting kinship estimates separately by group.
  type: File?
  inputBinding:
    prefix: --phenotype_file
    position: 20
    shellQuote: false
  sbg:category: Input Files
  sbg:fileTypes: RDATA
- id: group
  label: Group column name
  doc: |-
    Name of column in phenotype_file containing group variable (e.g., study) for plotting.
  type: string?
  inputBinding:
    prefix: --group
    position: 21
    shellQuote: false
  sbg:category: Input Options

outputs:
- id: kinship_plots
  label: Kinship plots
  doc: |-
    Hexbin plots of estimated kinship coefficients vs. IBS0. If "group" is provided, additional plots will be generated within each group and across groups.
  type: File[]
  outputBinding:
    glob: '*.pdf'
  sbg:fileTypes: PDF
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
  valueFrom: /usr/local/genesis-workflow/R/kinship_plots.R
  shellQuote: false

hints:
- class: sbg:SaveLogs
  value: '*.params'
- class: sbg:SaveLogs
  value: '*.log'
