cwlVersion: v1.2
class: CommandLineTool
label: pca_corr
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
  label: GDS File
  doc: Input GDS file
  type: File
  inputBinding:
    prefix: --gds_file
    position: 1
    shellQuote: false
  sbg:category: Input Files
  sbg:fileTypes: GDS
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
- id: pca_file
  label: PCA file
  doc: RData file with PCA results for unrelated samples
  type: File
  inputBinding:
    prefix: --pca_file
    position: 2
    shellQuote: false
  sbg:fileTypes: RDATA
- id: n_pcs_corr
  label: Number of PCs
  doc: Number of PCs (Principal Components) to use for PC-variant correlation
  type: int?
  default: 32
  inputBinding:
    prefix: --n_pcs
    position: 4
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: '32'
- id: out_file
  label: Output filename
  doc: Name for output file.
  type: string
  inputBinding:
    prefix: --out_file
    position: 3
    shellQuote: false
  sbg:category: Input Options
- id: chromosome
  label: Chromosome
  doc: Chromosome
  type: string?
  inputBinding:
    prefix: --chromosome
    position: 12
    shellQuote: false
  sbg:category: Input Options
- id: cpu
  label: cpu
  doc: Number of CPUs to use.
  type: int?
  default: 4
  inputBinding:
    prefix: --num_cores
    position: 20
    shellQuote: false

outputs:
- id: pca_corr_gds
  label: PC-SNP correlation
  doc: GDS file with PC-SNP correlation results
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
  valueFrom: /usr/local/genesis-workflow/R/pca_corr.R
  shellQuote: false

hints:
- class: sbg:SaveLogs
  value: '*.params'
- class: sbg:SaveLogs
  value: '*.log'
