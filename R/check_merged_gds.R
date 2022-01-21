library(argparser)
library(PipelineHelper)
library(SeqArray)
library(tools)
sessionInfo()

argp <- arg_parser("Check merged GDS")
argp <- add_argument(argp, "--gds_file", help="GDS file to check")
argp <- add_argument(argp, "--merged_gds_file", help="merged GDS file")
argv <- parse_args(argp)
writeParams(argv, "check_merged_gds.params")

## the chromosome-specific GDS file
gdsfile <- argv$gds_file
gds <- seqOpen(gdsfile)
message("File: ", basename(gdsfile), "\n")
hash_chr <- seqDigest(gds, "genotype")
message("MD5: ", hash_chr, "\n")
seqSetFilter(gds, variant.sel=1)
chr <- seqGetData(gds, "chromosome")
message("Chromosome: ", chr)
seqClose(gds)

## the merged GDS file
gds_merged_fn <- argv$merged_gds_file
gds_merge <- seqOpen(gds_merged_fn)
message("File: ", basename(gds_merged_fn), "\n")
seqSetFilterChrom(gds_merge, chr)
hash_merge <- seqDigest(gds_merge, "genotype")
message("MD5: ", hash_merge, "\n")
seqClose(gds_merge)


# check
stopifnot(hash_merge == hash_chr)

message("MD5 checking [OK]\n")
