library(argparser)
library(PipelineHelper)
library(SeqArray)
sessionInfo()

argp <- arg_parser("Subset GDS file")
argp <- add_argument(argp, "--gds_file", help="GDS file")
argp <- add_argument(argp, "--out_file", help="output file name")
argp <- add_argument(argp, "--sample_include_file",
                     help="RData file with vector of sample.id to include")
argp <- add_argument(argp, "--variant_include_file",
                     help="RData file with vector of variant.id to include")
argv <- parse_args(argp)
writeParams(argv, "subset_gds.params")

out_file <- argv$out_file
if (is.na(out_file)) {
    out_file <- paste0(tools::file_path_sans_ext(basename(argv$gds_file)), "_subset.gds")
}

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
seqExport(gds, out_file, fmt.var=character(), info.var=character())

seqClose(gds)
