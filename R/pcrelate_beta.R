library(argparser)
library(PipelineHelper)
library(SeqVarTools)
library(GENESIS)
sessionInfo()

argp <- arg_parser("PC-Relate")
argp <- add_argument(argp, "--gds_file", help="GDS file")
argp <- add_argument(argp, "--pca_file", 
                     help="RData file with pcair object")
argp <- add_argument(argp, "--n_pcs", default=3, type="integer",
                     help="number of PCs to use in adjusting for ancestry")
argp <- add_argument(argp, "--out_file", default="pcrelate_beta.RData",
                     help="output file name")
argp <- add_argument(argp, "--sample_include_file",
                     help="RData file with vector of sample.id to include")
argp <- add_argument(argp, "--variant_include_file",
                     help="RData file with vector of variant.id to include")
argp <- add_argument(argp, "--variant_block_size", default=1024, type="integer",
                     help="number of variants to read in a single block")
argp <- add_argument(argp, "--num_cores", default=1, type="integer",
                     help="number of cores")
argv <- parse_args(argp)
writeParams(argv, "pcrelate_beta.params")

# parallelization
if (argv$num_cores > 1) {
    BPPARAM <- BiocParallel::MulticoreParam(workers=argv$num_cores)
} else {
    BPPARAM <- BiocParallel::SerialParam()
}

gds <- seqOpen(argv$gds_file)
seqData <- SeqVarData(gds)

if (!is.na(argv$variant_include_file)) {
    filterByFile(seqData, argv$variant_include_file)
}

pca <- getobj(argv$pca_file)
n_pcs <- min(argv$n_pcs, length(pca$unrels))
pcs <- as.matrix(pca$vectors[,1:n_pcs])
sample.include <- samplesGdsOrder(seqData, pca$unrels)

if (!is.na(argv$sample_include_file)) {
    sample.id <- getobj(argv$sample_include_file)
    sample.include <- intersect(sample.include, sample.id)
}


# create iterator
iterator <- SeqVarBlockIterator(seqData, variantBlock=argv$variant_block_size)

beta <- calcISAFBeta(iterator,
                     pcs=pcs,
                     sample.include=sample.include,
                     BPPARAM=BPPARAM)

save(beta, file=argv$out_file)

seqClose(seqData)
