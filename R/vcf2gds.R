library(argparser)
library(PipelineHelper)
library(SeqArray)
library(tools)
sessionInfo()

argp <- arg_parser("Convert VCF to GDS")
argp <- add_argument(argp, "--vcf_file", help="VCF file")
argp <- add_argument(argp, "--gds_file", help="GDS file")
argp <- add_argument(argp, "--format", nargs=Inf,
                     help="format fields to import")
argp <- add_argument(argp, "--num_cores", default=1, type="integer",
                     help="number of cores")
argv <- parse_args(argp)
writeParams(argv, "vcf2gds.params")

gdsfile <- argv$gds_file
if (is.na(gdsfile)) {
    filebase <- tools::file_path_sans_ext(basename(sub(".gz$", "", argv$vcf_file)))
    gdsfile <- paste0(filebase, ".gds")
}

if (!is.na(argv$format)) {
    fmt.import <- argv$format
} else {
    fmt.import <- "GT"
}

## is this a bcf file?
ncores <- argv$num_cores
vcffile <- argv$vcf_file
isBCF <- file_ext(vcffile) == "bcf"
if (isBCF) {
    ## use bcftools to read text
    vcffile <- pipe(paste("bcftools view", vcffile), "rt")
    ncores <- FALSE # "No parallel support when the input is a connection object"
}

seqVCF2GDS(vcffile, gdsfile, fmt.import=fmt.import, storage.option="LZMA_RA",
           parallel=ncores)

if (isBCF) close(vcffile)
