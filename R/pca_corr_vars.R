library(argparser)
library(PipelineHelper)
library(SeqVarTools)
sessionInfo()

argp <- arg_parser("Select variants for correlation with PCs")
argp <- add_argument(argp, "--gds_file", help="GDS file")
argp <- add_argument(argp, "--pca_file", 
                     help="RData file with snpgdsPCAClass object")
argp <- add_argument(argp, "--n_corr_vars", default=10e6,
                     help="number of variants to sample across the genome")
argp <- add_argument(argp, "--out_file", default="pca_corr_variants.RData",
                     help="output file name")
argp <- add_argument(argp, "--variant_include_file",
                     help="RData file with vector of variant.id to include")
argp <- add_argument(argp, "--corr_maf_threshold", default=0.01,
                     help="MAF threshold for selecting variants")
argp <- add_argument(argp, "--corr_missing_threshold", default=0.05,
                     help="Missingness threshold for selecting variants")
argp <- add_argument(argp, "--chromosome", help="chromosome", type="character")
argv <- parse_args(argp)
writeParams(argv, "pca_corr_vars.params")

gds <- seqOpen(argv$gds_file)

## if we have a chromosome indicator but only one gds file, select chromosome
if (!is.na(argv$chromosome)) {
    message("Running on chromosome ", argv$chromosome)
    filterByChrom(gds, argv$chromosome)
    chr <- argv$chromosome
} else {
    ## if we don't have a chromosome argument, look up in GDS file
    chr <- unique(seqGetData(gds, "chromosome"))
}

filterByPass(gds)
filterBySNV(gds)

# Use only the samples included in PCA.
pca <- getobj(argv$pca_file)
seqSetFilter(gds, sample.id = pca$sample.id)

# Filter by MAF and missing rate
seqSetFilterCond(gds,
                 maf=argv$corr_maf_threshold,
                 missing.rate=argv$corr_missing_threshold)

vars <- seqGetData(gds, "variant.id")

seqClose(gds)

## get number of variants with same proportion of this chromosome in genome
prop <- c(0.079, 0.079, 0.063, 0.063, 0.060, 0.057, 0.051, 0.047, 
          0.044, 0.044, 0.044, 0.044, 0.038, 0.035, 0.035, 0.032,
          0.028, 0.028, 0.019, 0.022, 0.016, 0.019, 0.051)
names(prop) <- c(1:22, "X")
nvars <- sum(round(argv$n_corr_vars * prop[chr]))

if (length(vars) > nvars) {
    vars <- sort(sample(vars, nvars))
}
message("selected ", length(vars), " variants")

## add pruned variants
if (!is.na(argv$variant_include_file)) {
    pruned <- getobj(argv$variant_include_file)
    vars <- sort(unique(c(vars, pruned)))
}
message(length(vars), " total variants")

save(vars, file=argv$out_file)
