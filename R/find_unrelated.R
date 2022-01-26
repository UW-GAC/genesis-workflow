library(argparser)
library(PipelineHelper)
library(Biobase)
library(GENESIS)
sessionInfo()

argp <- arg_parser("Partition samples into related and unrelated sets")
argp <- add_argument(argp, "--kinship_file", 
                     help="File containing kinship matrix to use for defining unrelated samples")
argp <- add_argument(argp, "--divergence_file", 
                     help="File containing kinship matrix to use for ancestry divergence")
argp <- add_argument(argp, "--kinship_threshold", default=0.04419417, 
                     help="Minimum kinship for assigning relatives, default 2^(-9/2), 3rd degree")
argp <- add_argument(argp, "--divergence_threshold", default=-0.04419417, 
                     help="Minimum kinship for ancestry divergence, default 2^(-9/2), 3rd degree")
argp <- add_argument(argp, "--out_prefix", default="samples", 
                     help="prefix for output files")
argp <- add_argument(argp, "--phenotype_file", 
                     help="RData file with sample.id and group columns")
argp <- add_argument(argp, "--sample_include_file", 
                     help="RData file with vector of sample.id to include")
argp <- add_argument(argp, "--group", 
                     help="Name of column in phenotype_file with group indicator")
argv <- parse_args(argp)
writeParams(argv, "find_unrelated.params")

if (!is.na(argv$sample_include_file)) {
    sample.id <- getobj(argv$sample_include_file)
    message("Using ", length(sample.id), " samples")
} else {
    sample.id <- NULL
    message("Using all samples")
}

kinMat <- kinobj(argv$kinship_file)

if (!is.na(argv$divergence_file)) {
    divMat <- kinobj(argv$divergence_file)
    message("Using divergence matrix to find unrelated set")
} else {
    divMat <- NULL
    message("No divergence matrix specified")
}

kin_thresh <- argv$kinship_threshold
div_thresh <- argv$divergence_threshold

## for each group, find median kinship coefficient
## if median KC > 0, run find_unrelated on that group only, with threshold of 2^(-9/2) + median KC
if (!is.na(argv$group) & !is.na(argv$phenotype_file)) {
    # could replace this with a read.gdsn command, but unlikely we will need it
    if (is(kinMat, "gds.class")) stop("can't compute median kinship by group on GDS object")
    message("Computing median kinship by group")
    
    group <- argv$group
    annot <- getobj(argv$phenotype_file)
    if (is(annot, "AnnotatedDataFrame")) {
        annot <- pData(annot)
    }
    stopifnot(group %in% names(annot))
    annot <- annot[,c("sample.id", group)]
    names(annot)[2] <- "group"
    if (!is.null(sample.id)) {
        annot <- annot[annot$sample.id %in% sample.id,]
    }
    studies <- unique(annot$group)
    group.partition <- list()
    for (s in studies) {
        ids <- annot$sample.id[annot$group %in% s]
        ind <- rownames(kinMat) %in% ids
        medKC <- medianKinship(kinMat[ind,ind])
        if (medKC > 0) {
            message("Median kinship for ", s, " is ", medKC, ".\n",
                    "Finding unrelated set separately.")
            group.partition[[s]] <- pcairPartition(kinobj=kinMat, kin.thresh=(kin_thresh + medKC),
                                                   divobj=divMat, div.thresh=div_thresh,
                                                   sample.include=ids)
            message("Found ", length(group.partition[[s]]$unrels), " unrelated and ", length(group.partition[[s]]$rels), " related samples")
        }
    }
    
    ## combine unrelated samples from individual studies
    # will be NULL if list is empty
    group.unrel <- unlist(lapply(group.partition, function(x) x$unrels), use.names=FALSE)
} else {
    group.unrel <- NULL
}


## run pcairPartition on everyone, forcing list of per-group unrel into unrelated set
part <- pcairPartition(kinobj=kinMat, kin.thresh=kin_thresh,
                       divobj=divMat, div.thresh=div_thresh,
                       sample.include=sample.id,
                       unrel.set=group.unrel)

rels <- part$rels
unrels <- part$unrels
save(rels, file=paste0(argv$out_prefix, "_related.RData"))
save(unrels, file=paste0(argv$out_prefix, "_unrelated.RData"))
message("Found ", length(unrels), " unrelated and ", length(rels), " related samples")
