library(argparser)
library(PipelineHelper)
library(SeqArray)
library(SNPRelate)
sessionInfo()

argp <- arg_parser("Convert GDS to BED")
argp <- add_argument(argp, "--gds_file", help="GDS file")
argp <- add_argument(argp, "--out_file", help="output file name")
argp <- add_argument(argp, "--sample_include_file",
                     help="RData file with vector of sample.id to include")
argp <- add_argument(argp, "--variant_include_file",
                     help="RData file with vector of variant.id to include")
argv <- parse_args(argp)
writeParams(argv, "gds2bed.params")

out_file <- argv$out_file
if (is.na(out_file)) {
    out_file <- tools::file_path_sans_ext(basename(argv$gds_file))
}

gds <- seqOpen(argv$gds_file)

if (!is.na(argv$variant_include_file)) {
    filterByFile(gds, argv$variant_include_file)
}

if (!is.na(argv$sample_include_file)) {
    sample.id <- getobj(argv$sample_include_file)
    seqSetFilter(gds, sample.id=sample.id)
}

snpfile <- tempfile()
seqGDS2SNP(gds, snpfile)
seqClose(gds)

gds <- snpgdsOpen(snpfile)
snpgdsGDS2BED(gds, out_file)
snpgdsClose(gds)

unlink(snpfile)
