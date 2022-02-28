cwlVersion: v1.2
class: CommandLineTool
label: find_unrelated
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
  doc: |-
    Pairwise kinship matrix used to identify unrelated and related sets of samples. It is recommended to use KING-IBDseg or PC-Relate estimates.
  type: File
  inputBinding:
    prefix: --kinship_file
    position: 1
    shellQuote: false
  sbg:category: Input Files
  sbg:fileTypes: RDATA, GDS
- id: divergence_file
  label: Divergence File
  doc: |-
    Pairwise matrix used to identify ancestrally divergent pairs of samples. It is recommended to use KING-robust estimates.
  type: File?
  inputBinding:
    prefix: --divergence_file
    position: 2
    shellQuote: false
  sbg:category: Input Files
  sbg:fileTypes: RDATA, GDS
- id: kinship_threshold
  label: Kinship threshold
  doc: Minimum kinship estimate to use for identifying relatives.
  type: float?
  inputBinding:
    prefix: --kinship_threshold
    position: 3
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: 2^(-9/2) (third-degree relatives and closer)
- id: divergence_threshold
  label: Divergence threshold
  doc: |-
    Maximum divergence estimate to use for identifying ancestrally divergent pairs of samples.
  type: float?
  inputBinding:
    prefix: --divergence_threshold
    position: 4
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: -2^(-9/2)
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
  label: Sample Include file
  doc: |-
    RData file with vector of sample.id to include. If not provided, all samples in the kinship file are included.
  type: File?
  inputBinding:
    prefix: --sample_include_file
    position: 10
    shellQuote: false
  sbg:category: Input Files
  sbg:fileTypes: RDATA
- id: phenotype_file
  label: Phenotype File
  doc: |-
    RData file with data.frame or AnnotatedDataFrame of phenotypes. Used for identfying groups with median kinship > 0 that need relatedness assessed separately.
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
    Name of column in phenotype_file containing group variable (e.g., study).
  type: string?
  inputBinding:
    prefix: --group
    position: 21
    shellQuote: false
  sbg:category: Input Options

outputs:
- id: out_related_file
  label: Related file
  doc: |-
    RData file with vector of sample.id of samples related to the set of unrelated samples
  type: File
  outputBinding:
    glob: |-
      ${ 
        return inputs.out_prefix + "_related.RData"
      }
  sbg:fileTypes: RDATA
- id: out_unrelated_file
  label: Unrelated file
  doc: RData file with vector of sample.id of unrelated samples
  type: File
  outputBinding:
    glob: |-
      ${
          return inputs.out_prefix + "_unrelated.RData"
      }
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
  valueFrom: /usr/local/genesis-workflow/R/find_unrelated.R
  shellQuote: false

hints:
- class: sbg:SaveLogs
  value: '*.params'
- class: sbg:SaveLogs
  value: '*.log'
