library(argparser)
library(PipelineHelper)
library(SeqVarTools)
library(GENESIS)
sessionInfo()

argp <- arg_parser("PC-Relate")
argp <- add_argument(argp, "--gds_file", help="GDS file")
argp <- add_argument(argp, "--pca_file", 
                     help="RData file with pcair object")
argp <- add_argument(argp, "--beta_file", 
                     help="file with output from pcrelate_beta")
argp <- add_argument(argp, "--n_pcs", default=3, type="integer",
                     help="number of PCs to use in adjusting for ancestry")
argp <- add_argument(argp, "--out_prefix", default="pca", 
                     help="prefix for output files")
argp <- add_argument(argp, "--sample_include_file",
                     help="RData file with vector of sample.id to include")
argp <- add_argument(argp, "--variant_include_file",
                     help="RData file with vector of variant.id to include")
argp <- add_argument(argp, "--variant_block_size", default=1024, type="integer",
                     help="number of variants to read in a single block")
argp <- add_argument(argp, "--ibd_probs", default=TRUE,
                     help="logical for whether to return IBD probabilities (needed for plotting)")
argp <- add_argument(argp, "--num_cores", default=1, type="integer",
                     help="number of cores")
argp <- add_argument(argp, "--n_sample_blocks", default=1, type="integer", 
                     help="number of blocks to divide samples into for parallel computation")
argp <- add_argument(argp, "--i", default=1, type="integer", 
                     help="index of first sample block for this job")
argp <- add_argument(argp, "--j", default=1, type="integer", 
                     help="index of second sample block for this job")
argv <- parse_args(argp)
writeParams(argv, "pcrelate.params")

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
n_pcs <- min(as.integer(argv$n_pcs), length(pca$unrels))
pcs <- as.matrix(pca$vectors[,1:n_pcs])
sample.include <- samplesGdsOrder(seqData, rownames(pcs))

if (!is.na(argv$sample_include_file)) {
    sample.id <- getobj(argv$sample_include_file)
    sample.include <- intersect(sample.include, sample.id)
}

# load betas
beta <- getobj(argv$beta_file)

# create iterator
block.size <- argv$variant_block_size
iterator <- SeqVarBlockIterator(seqData, variantBlock=block.size)

# create sample blocks
nsampblock <- argv$n_sample_blocks
i <- argv$i
j <- argv$j
if (nsampblock > 1) {
    samp.blocks <- unname(split(sample.include, cut(1:length(sample.include), nsampblock)))

    # map segment number to sample block numbers
    ## jobs <- list()
    ## s <- 1
    ## for (i in 1:nsampblock) {
    ##     for (j in i:nsampblock) {
    ##         jobs[[s]] <- c(i,j)
    ##         s <- s + 1
    ##     }
    ## }
    # jobs <- c(combn(1:nsampblock, 2, simplify=FALSE),
    #           lapply(1:nsampblock, function(x) c(x,x)))
    # i <- jobs[[argv$sample_block]][1]
    # j <- jobs[[argv$sample_block]][2]
} else {
    samp.blocks <- list(sample.include)
    i <- j <- 1
}

out <- pcrelateSampBlock(iterator,
                         betaobj=beta,
                         pcs=pcs,
                         sample.include.block1=samp.blocks[[i]],
                         sample.include.block2=samp.blocks[[j]],
                         ibd.probs=argv$ibd_probs,
                         BPPARAM=BPPARAM)

save(out, file=paste0(argv$out_prefix, "_block_", i, "_", j, ".RData"))

seqClose(seqData)
