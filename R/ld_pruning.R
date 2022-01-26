library(argparser)
library(PipelineHelper)
library(SeqVarTools)
library(SNPRelate)
sessionInfo()

argp <- arg_parser("LD pruning")
argp <- add_argument(argp, "--gds_file", help="GDS file")
argp <- add_argument(argp, "--out_file", default="pruned_variants.RData",
                     help="output file name")
argp <- add_argument(argp, "--autosome_only", default=TRUE,
                     help="Only include autosomes")
argp <- add_argument(argp, "--exclude_pca_corr", default=TRUE,
                     help="Exclude variants in regions with high correlation with PCs (HLA, LCT, inversions)")
argp <- add_argument(argp, "--genome_build", default="hg38",
                     help="Genome build, used to define correlation regions")
argp <- add_argument(argp, "--ld_r_threshold", default=0.32,
                     help="r threshold. Default is r^2 = 0.1")
argp <- add_argument(argp, "--ld_win_size", default=10,
                     help="Sliding window size in Mb")
argp <- add_argument(argp, "--maf_threshold", default=0.01,
                     help="Minimum MAF for variants used")
argp <- add_argument(argp, "--missing_threshold", default=0.01,
                     help="Maximum missing call rate for variants used")
argp <- add_argument(argp, "--sample_include_file",
                     help="RData file with vector of sample.id to include")
argp <- add_argument(argp, "--variant_include_file",
                     help="RData file with vector of variant.id to include")
argp <- add_argument(argp, "--chromosome", help="chromosome", type="character")
argv <- parse_args(argp)
writeParams(argv, "ld_pruning.params")

if (argv$chromosome %in% "X" & argv$autosome_only) stop("Set autosome_only=FALSE to prune X chrom variants")

gds <- seqOpen(argv$gds_file)

if (!is.na(argv$sample_include_file)) {
    sample.id <- getobj(argv$sample_include_file)
    message("Using ", length(sample.id), " samples")
} else {
    sample.id <- NULL
    message("Using all samples")
}

if (!is.na(argv$variant_include_file)) {
    filterByFile(gds, argv$variant_include_file)
}

## if we have a chromosome indicator but only one gds file, select chromosome
if (!is.na(argv$chromosome)) {
    message("Running on chromosome ", argv$chromosome)
    filterByChrom(gds, argv$chromosome)
}

filterByPass(gds)
filterBySNV(gds)
if (argv$exclude_pca_corr) {
    filterByPCAcorr(gds, build=argv$genome_build)
}

variant.id <- seqGetData(gds, "variant.id")
message("Using ", length(variant.id), " variants")

set.seed(100) # make pruned SNPs reproducible
snpset <- snpgdsLDpruning(gds,
                          sample.id=sample.id,
                          snp.id=variant.id,
                          autosome.only=argv$autosome_only,
                          maf=argv$maf_threshold,
                          missing.rate=argv$missing_threshold,
                          method="corr", slide.max.bp=argv$ld_win_size*1e6,
                          ld.threshold=argv$ld_r_threshold)

pruned <- unlist(snpset, use.names=FALSE)
save(pruned, file=argv$out_file)

seqClose(gds)
