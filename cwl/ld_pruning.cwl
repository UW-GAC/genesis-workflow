cwlVersion: v1.2
class: CommandLineTool
label: ld_pruning
$namespaces:
  sbg: https://sevenbridges.com

requirements:
- class: ShellCommandRequirement
- class: DockerRequirement
  dockerPull: uwgac/analysis_pipeline_3:0.1.0
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
  sbg:category: Input files
  sbg:fileTypes: GDS
- id: ld_r_threshold
  label: LD |r| threshold
  doc: '|r| threshold for LD pruning.'
  type: float?
  inputBinding:
    prefix: --ld_r_threshold
    position: 2
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: 0.32 (r^2 = 0.1)
- id: ld_win_size
  label: LD window size
  doc: Sliding window size in Mb for LD pruning.
  type: float?
  inputBinding:
    prefix: --ld_win_size
    position: 3
    shellQuote: false
  sbg:category: Input options
  sbg:toolDefaultValue: '10'
- id: maf_threshold
  label: MAF threshold
  doc: |-
    Minimum MAF for variants used in LD pruning. Variants below this threshold are removed.
  type: float?
  inputBinding:
    prefix: --maf_threshold
    position: 4
    shellQuote: false
  sbg:category: Input options
  sbg:toolDefaultValue: '0.01'
- id: missing_threshold
  label: Missing call rate threshold
  doc: |-
    Maximum missing call rate for variants used in LD pruning. Variants above this threshold are removed.
  type: float?
  inputBinding:
    prefix: --missing_threshold
    position: 5
    shellQuote: false
  sbg:category: Input options
  sbg:toolDefaultValue: '0.01'
- id: out_prefix
  label: Output prefix
  doc: Prefix for output files.
  type: string?
  inputBinding:
    prefix: --out_prefix
    position: 6
    shellQuote: false
  sbg:category: Input Options
- id: sample_include_file
  label: Sample Include file
  doc: |-
    RData file with vector of sample.id to include. If not provided, all samples in the GDS file are included.
  type: File?
  inputBinding:
    prefix: --sample_include_file
    position: 7
    shellQuote: false
  sbg:category: Input Files
  sbg:fileTypes: RDATA
- id: variant_include_file
  label: Variant Include file
  doc: |-
    RData file with vector of variant.id to consider for LD pruning. If not provided, all variants in the GDS file are included.
  type: File?
  inputBinding:
    prefix: --variant_include_file
    position: 8
    shellQuote: false
  sbg:category: Input Files
  sbg:fileTypes: RDATA
- id: exclude_pca_corr
  label: Exclude PCA corr
  doc: |-
    Exclude variants in genomic regions known to result in high PC-variant correlations when included (HLA, LCT, inversions).
  type:
  - 'null'
  - name: exclude_pca_corr
    type: enum
    symbols:
    - "TRUE"
    - "FALSE"
  default: "TRUE"
  inputBinding:
    prefix: --exclude_pca_corr
    position: 9
    shellQuote: false
  sbg:category: Input options
  sbg:toolDefaultValue: 'true'
- id: genome_build
  label: Genome build
  doc: |-
    Genome build, used to define genomic regions to filter for PC-variant correlation.
  type:
  - 'null'
  - name: genome_build
    type: enum
    symbols:
    - hg18
    - hg19
    - hg38
  default: hg38
  inputBinding:
    prefix: --genome_build
    position: 10
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: hg38
- id: chromosome
  label: Chromosome
  doc: Chromosome
  type: string?
  inputBinding:
    prefix: --chromosome
    position: 20
    shellQuote: false
  sbg:category: Input Options
- id: autosome_only
  label: Autosomes only
  doc: Only include variants on the autosomes.
  type:
  - 'null'
  - name: autosome_only
    type: enum
    symbols:
    - "TRUE"
    - "FALSE"
  default: "TRUE"
  inputBinding:
    prefix: --autosome_only
    position: 21
    shellQuote: false
  sbg:category: Input options
  sbg:toolDefaultValue: 'true'

outputs:
- id: ld_pruning_output
  label: Pruned output file
  doc: RData file with variant.id of pruned variants.
  type: File?
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
  valueFrom: /usr/local/analysis_pipeline_cwl/R/ld_pruning.R
  shellQuote: false

hints:
- class: sbg:SaveLogs
  value: "*.params"
- class: sbg:SaveLogs
  value: "*.log"
