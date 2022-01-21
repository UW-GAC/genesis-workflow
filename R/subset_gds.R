library(argparser)
library(PipelineHelper)
library(SeqArray)
sessionInfo()

argp <- arg_parser("Subset GDS file")
argp <- add_argument(argp, "--gds_file", help="GDS file")
argp <- add_argument(argp, "--subset_gds_file", help="GDS file after subsetting")
argp <- add_argument(argp, "--sample_include_file",
                     help="RData file with vector of sample.id to include")
argp <- add_argument(argp, "--variant_include_file",
                     help="RData file with vector of variant.id to include")
argv <- parse_args(argp)
writeParams(argv, "subset_gds.params")

gds <- seqOpen(argv$gds_file)

if (!is.na(argv$sample_include_file)) {
    sample.id <- getobj(argv$sample_include_file)
} else {
    sample.id <- NULL
}

if (!is.na(argv$variant_include_file)) {
    variant.id <- getobj(argv$variant_include_file)
} else {
    variant.id <- NULL
}

seqSetFilter(gds, sample.id=sample.id, variant.id=variant.id)
seqExport(gds, argv$subset_gds_file, fmt.var=character(), info.var=character())

seqClose(gds)
