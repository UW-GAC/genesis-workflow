cwlVersion: v1.2
class: CommandLineTool
label: pca_byrel
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
  doc: |-
    Input GDS file used for PCA. It is recommended to use an LD pruned file with all chromosomes.
  type: File
  inputBinding:
    prefix: --gds_file
    position: 1
    shellQuote: false
  sbg:category: Input Files
  sbg:fileTypes: GDS
- id: related_file
  label: Related file
  doc: RData file with related subjects.
  type: File
  inputBinding:
    prefix: --related_file
    position: 2
    shellQuote: false
  sbg:category: Input Files
  sbg:fileTypes: RDATA
- id: unrelated_file
  label: Unrelated file
  doc: RData file with unrelated subjects.
  type: File
  inputBinding:
    prefix: --unrelated_file
    position: 3
    shellQuote: false
  sbg:category: Input Files
  sbg:fileTypes: RDATA
- id: sample_include_file
  label: Sample Include file
  doc: |-
    RData file with vector of sample.id to include. If not provided, all samples in the GDS file are included.
  type: File?
  inputBinding:
    prefix: --sample_include_file
    position: 10
    shellQuote: false
  sbg:category: Input Files
  sbg:fileTypes: RDATA
- id: variant_include_file
  label: Variant include file
  doc: |-
    RData file with vector of variant.id to include. If not provided, all variants in the GDS file are included.
  type: File?
  inputBinding:
    prefix: --variant_include_file
    position: 11
    shellQuote: false
  sbg:category: Input Options
  sbg:fileTypes: RDATA
- id: n_pcs
  label: Number of PCs
  doc: Number of PCs (Principal Components) to return.
  type: int?
  default: 32
  inputBinding:
    prefix: --n_pcs
    position: 4
    shellQuote: false
  sbg:category: Input Options
  sbg:toolDefaultValue: '32'
- id: out_prefix
  label: Output prefix
  doc: Prefix for output files.
  type: string
  inputBinding:
    prefix: --out_prefix
    position: 5
    shellQuote: false
    valueFrom: |-
      ${
        return self + '_pca'
      }
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
  sbg:category: Input Options
  sbg:toolDefaultValue: '4'

outputs:
- id: pcair_output
  label: RData file with PC-AiR PCs for all samples
  type: File
  outputBinding:
    glob: |-
      ${
        return inputs.out_prefix + "_pca.RData"
      }
  sbg:fileTypes: RDATA
- id: pcair_output_unrelated
  label: PCA byrel unrelated
  doc: RData file with PC-AiR PCs for unrelated samples
  type: File
  outputBinding:
    glob: |-
      ${
        return inputs.out_prefix + "_pca_unrel.RData"
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
  valueFrom: /usr/local/genesis-workflow/R/pca_byrel.R
  shellQuote: false

hints:
- class: sbg:SaveLogs
  value: '*.params'
- class: sbg:SaveLogs
  value: '*.log'
