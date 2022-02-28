cwlVersion: v1.2
class: CommandLineTool
label: pca_corr_vars
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
  doc: Input GDS file
  type: File
  inputBinding:
    prefix: --gds_file
    position: 1
    shellQuote: false
  sbg:category: Input Files
  sbg:fileTypes: GDS
- id: pca_file
  label: PCA File
  doc: RData file containing unrelated pcair object (output by pca_byrel tool)
  type: File
  inputBinding:
    prefix: --pca_file
    position: 2
    shellQuote: false
  sbg:category: Input Files
  sbg:fileTypes: RDATA
- id: variant_include_file
  label: Variant include file
  doc: |-
    RData file with vector of variant.id to include. These variants will be added to the set of randomly selected variants. It is recommended to provide the set of pruned variants used for PCA.
  type: File?
  inputBinding:
    prefix: --variant_include_file
    position: 11
    shellQuote: false
  sbg:category: Input Options
  sbg:fileTypes: RDATA
- id: out_file
  label: Output filename
  doc: Name for output file.
  type: string
  inputBinding:
    prefix: --out_file
    position: 3
    shellQuote: false
  sbg:category: Input Options
- id: n_corr_vars
  label: Number of variants to select
  doc: |-
    Randomly select this number of variants distributed across the entire genome to use for PC-variant correlation. If running on a single chromosome, the variants returned will be scaled by the proportion of that chromosome in the genome.
  type: int?
  inputBinding:
    prefix: --n_corr_vars
    position: 4
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: '10e6'
- id: corr_maf_threshold
  label: MAF threshold
  doc: |-
    Minimum MAF for variants used in LD pruning. Variants below this threshold are removed.
  type: float?
  inputBinding:
    prefix: --corr_maf_threshold
    position: 8
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: '0.01'
- id: corr_missing_threshold
  label: Missing call rate threshold
  doc: |-
    Maximum missing call rate for variants used in LD pruning. Variants above this threshold are removed.
  type: float?
  inputBinding:
    prefix: --corr_missing_threshold
    position: 9
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: '0.05'
- id: chromosome
  label: Chromosome
  doc: Chromosome
  type: string?
  inputBinding:
    prefix: --chromosome
    position: 12
    shellQuote: false
  sbg:category: Input Options

outputs:
- id: pca_corr_vars
  label: Variants to use for PC correlation
  doc: |-
    RData file with a randomly selected set of variant.ids distributed across the genome, plus any variants from variant_include_file.
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
  valueFrom: /usr/local/genesis-workflow/R/pca_corr_vars.R
  shellQuote: false

hints:
- class: sbg:SaveLogs
  value: '*.params'
- class: sbg:SaveLogs
  value: '*.log'
