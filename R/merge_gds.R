library(argparser)
library(PipelineHelper)
library(SeqArray)
sessionInfo()

argp <- arg_parser("Merge per-chromosome GDS files into single GDS file")
argp <- add_argument(argp, "--gds_file", nargs=Inf,
                     help="GDS files to merge")
argp <- add_argument(argp, "--merged_gds_file", 
                     help="output file name")
argv <- parse_args(argp)
writeParams(argv, "merge_gds.params")

## merge genotypes only (no other format or info fields)
seqMerge(argv$gds_file, argv$merged_gds_file, fmt.var=character(), info.var=character(), storage.option="LZMA_RA")
