library(argparser)
library(PipelineHelper)
library(SeqVarTools)
library(SNPRelate)
sessionInfo()

argp <- arg_parser("PCA on unrelated set, project relatives")
argp <- add_argument(argp, "--gds_file", help="GDS file")
argp <- add_argument(argp, "--related_file", 
                     help="RData file with vector of sample.id for unrelated samples")
argp <- add_argument(argp, "--unrelated_file", 
                     help="RData file with vector of sample.id for unrelated samples")
argp <- add_argument(argp, "--out_prefix", default="pca", 
                     help="prefix for output files")
argp <- add_argument(argp, "--n_pcs", default=32, type="integer",
                     help="number of PCs to return")
argp <- add_argument(argp, "--sample_include_file",
                     help="RData file with vector of sample.id to include")
argp <- add_argument(argp, "--variant_include_file",
                     help="RData file with vector of variant.id to include")
argp <- add_argument(argp, "--num_cores", default=1, type="integer",
                     help="number of cores")
argv <- parse_args(argp)
writeParams(argv, "pca_byrel.params")

gds <- seqOpen(argv$gds_file)

rels <- getobj(argv$related_file)
unrels <- getobj(argv$unrelated_file)

if (!is.na(argv$sample_include_file)) {
    sample.id <- as.character(getobj(argv$sample_include_file))
    rels <- intersect(rels, sample.id)
    unrels <- intersect(unrels, sample.id)
}
message("Using ", length(unrels), " unrelated and ", length(rels), " related samples")

if (!is.na(argv$variant_include_file)) {
    variant.id <- getobj(argv$variant_include_file)
    message("Using ", length(variant.id), " variants")
} else {
    variant.id <- NULL
}

# number of PCs to return
n_pcs <- min(argv$n_pcs, length(unrels))

# run PCA on unrelated set
message("PCA on unrelated set")
pca.unrel <- snpgdsPCA(gds, sample.id=unrels, snp.id=variant.id,
                       algorithm="randomized", eigen.cnt=n_pcs, num.thread=argv$num_cores)
save(pca.unrel, file=paste0(argv$out_prefix, "_unrel.RData"))

# project values for relatives
message("PCA projection for related set")
snp.load <- snpgdsPCASNPLoading(pca.unrel, gdsobj=gds, num.thread=argv$num_cores)
samp.load <- snpgdsPCASampLoading(snp.load, gdsobj=gds, sample.id=rels, num.thread=argv$num_cores)

# combine unrelated and related PCs and order as in GDS file
eigenvect <- rbind(pca.unrel$eigenvect, samp.load$eigenvect)
rownames(eigenvect) <- c(pca.unrel$sample.id, samp.load$sample.id)
seqSetFilter(gds, sample.id=rownames(eigenvect), verbose=FALSE)
sample.id <- seqGetData(gds, "sample.id")
samp.ord <- match(sample.id, rownames(eigenvect))
eigenvect <- eigenvect[samp.ord,]

# output object
pca <- list(vectors=eigenvect,
            values=pca.unrel$eigenval[1:n_pcs],
            varprop=pca.unrel$varprop[1:n_pcs],
            rels=rels,
            unrels=unrels)

save(pca, file=paste0(argv$out_prefix, ".RData"))

seqClose(gds)
