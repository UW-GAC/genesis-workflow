library(argparser)
library(PipelineHelper)
library(SeqVarTools)
library(SNPRelate)
sessionInfo()

argp <- arg_parser("IBD with KING-robust")
argp <- add_argument(argp, "--gds_file", help="GDS file")
argp <- add_argument(argp, "--out_file", default="king_robust.gds", 
                     help="output file name (should end in .gds)")
argp <- add_argument(argp, "--sample_include_file",
                     help="RData file with vector of sample.id to include")
argp <- add_argument(argp, "--variant_include_file",
                     help="RData file with vector of variant.id to include")
argp <- add_argument(argp, "--num_cores", default=1, type="integer",
                     help="number of cores")
argv <- parse_args(argp)
writeParams(argv, "ibd_king.params")

gds <- seqOpen(argv$gds_file)

if (!is.na(argv$sample_include_file)) {
    sample.id <- getobj(argv$sample_include_file)
    message("Using ", length(sample.id), " samples")
} else {
    sample.id <- NULL
    message("Using all samples")
}

if (!is.na(argv$variant_include_file)) {
    variant.id <- getobj(argv$variant_include_file)
    message("Using ", length(variant.id), " variants")
} else {
    variant.id <- NULL
    message("Using all variants")
}

ibd <- snpgdsIBDKING(gds, sample.id=sample.id, snp.id=variant.id,
                     num.thread=argv$num_cores)

list2gds(ibd, argv$out_file)

seqClose(gds)
