library(argparser)
library(PipelineHelper)
library(SeqVarTools)
library(SNPRelate)
library(gdsfmt)
sessionInfo()

argp <- arg_parser("Correlation of variants with PCs")
argp <- add_argument(argp, "--gds_file", help="GDS file")
argp <- add_argument(argp, "--pca_file", 
                     help="RData file with pcair object")
argp <- add_argument(argp, "--n_pcs", default=32, type="integer",
                     help="number of PCs to return")
argp <- add_argument(argp, "--out_file", default="pca_corr_variants.RData",
                     help="output file name")
argp <- add_argument(argp, "--variant_include_file",
                     help="RData file with vector of variant.id to include")
argp <- add_argument(argp, "--chromosome", help="chromosome", type="character")
argp <- add_argument(argp, "--num_cores", default=1, type="integer",
                     help="number of cores")
argv <- parse_args(argp)
writeParams(argv, "pca_corr.params")

gds <- seqOpen(argv$gds_file)

## if we have a chromosome indicator but only one gds file, select chromosome
if (!is.na(argv$chromosome)) {
    message("Running on chromosome ", argv$chromosome)
    filterByChrom(gds, argv$chromosome)
}

if (!is.na(argv$variant_include_file)) {
    filterByFile(gds, argv$variant_include_file)
} else {
    filterByPass(gds)
    filterBySNV(gds)
}

variant.id <- seqGetData(gds, "variant.id")
message("Using ", length(variant.id), " variants")

pca <- getobj(argv$pca_file)
n_pcs <- min(argv$n_pcs, length(pca$sample.id))
snpgdsPCACorr(pca, gdsobj=gds, snp.id=variant.id, eig.which=1:n_pcs,
              num.thread=argv$num_cores, outgds=argv$out_file)

## add chromosome and position to output
seqSetFilter(gds, variant.id=variant.id)
chromosome <- seqGetData(gds, "chromosome")
position <- seqGetData(gds, "position")
seqClose(gds)

pca.corr <- openfn.gds(argv$out_file, readonly=FALSE)
add.gdsn(pca.corr, "chromosome", chromosome, compress="LZMA_RA")
add.gdsn(pca.corr, "position", position, compress="LZMA_RA")
closefn.gds(pca.corr)
cleanup.gds(argv$out_file)
