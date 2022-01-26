library(argparser)
library(PipelineHelper)
library(SNPRelate)
library(GENESIS)
library(gdsfmt)
library(Biobase)
library(readr)
library(dplyr)
library(ggplot2)
library(hexbin)
sessionInfo()

argp <- arg_parser("Kinship plots")
argp <- add_argument(argp, "--kinship_file", help="file with kinship estimates")
argp <- add_argument(argp, "--kinship_method", default="king_ibdseg", 
                     help="method used to generate kinship estimates")
argp <- add_argument(argp, "--kinship_threshold", default=0.04419417, 
                     help="threshold for king_robust results, default 2^(-9/2), 3rd degree")
argp <- add_argument(argp, "--out_prefix", default="kinship", 
                     help="prefix for output files")
argp <- add_argument(argp, "--sample_include_file", 
                     help="RData file with vector of sample.id to include")
argp <- add_argument(argp, "--phenotype_file", 
                     help="RData file with sample.id and group columns")
argp <- add_argument(argp, "--group", 
                     help="Name of column in phenotype_file with group indicator")
argv <- parse_args(argp)
writeParams(argv, "kinship_plots.params")

if (!is.na(argv$sample_include_file)) {
    sample.id <- getobj(argv$sample_include_file)
} else {
    sample.id <- NULL
}

## select type of kinship estimates to use (king or pcrelate)
kin.type <- tolower(argv$kinship_method)
if (kin.type == "king_ibdseg") {
    kinship <- read_tsv(argv$kinship_file, col_types="-c-c--nnn-") %>%
        mutate(IBS0=(1 - IBD1Seg - IBD2Seg), kinship=0.5*PropIBD)
    xvar <- "IBS0"
} else if (kin.type == "king_related") {
    kinship <- read_tsv(argv$kinship_file, col_types="-cc----n--n-----") %>%
        rename(kinship=Kinship)
    xvar <- "IBS0"
} else if (kin.type == "king_kinship") {
    kinship <- read_tsv(argv$kinship_file, col_types="-cc----nn-") %>%
        rename(kinship=Kinship)
    xvar <- "IBS0"
} else if (kin.type == "king_robust") {
    if (tools::file_ext(argv$kinship_file) == "gds") {
        king <- gds2ibdobj(argv$kinship_file, sample.id=sample.id)
        kinship <- snpgdsIBDSelection(king, kinship.cutoff=argv$kinship_threshold)
    } else {
        king <- getobj(argv$kinship_file)
        samp.sel <- if (is.null(sample.id)) NULL else king$sample.id %in% sample.id
        kinship <- snpgdsIBDSelection(king, kinship.cutoff=argv$kinship_threshold, samp.sel=samp.sel)
    }
    xvar <- "IBS0"
    rm(king)
} else if (kin.type == "pcrelate") {
    pcr <- getobj(argv$kinship_file)
    kinship <- pcr$kinBtwn %>%
        rename(kinship=kin) %>%
        select(ID1, ID2, k0, kinship)
    xvar <- "k0"
    rm(pcr)
} else {
    stop("kinship method should be 'king' or 'pcrelate'")
}
message("Plotting ", kin.type, " kinship estimates")

p <- ggplot(kinship, aes_string(xvar, "kinship")) +
    geom_hline(yintercept=2^(-seq(3,11,2)/2), linetype="dashed", color="grey") +
    ## geom_point(alpha=0.5) +
    ## theme_bw()
    geom_hex(aes(fill = log10(..count..)), bins = 100) +
    ylab("kinship estimate")

ggsave(paste0(argv$out_prefix, "_all.pdf"), plot=p, width=6, height=6)


## plot separately by group
if (!is.na(argv$phenotype_file) & !is.na(argv$group)) {
    group <- argv$group
    message("Plotting by group variable ", group)

    annot <- getobj(argv$phenotype_file)
    if (is(annot, "AnnotatedDataFrame")) {
        annot <- pData(annot)
    }
    stopifnot(group %in% names(annot))
    annot <- select_(annot, "sample.id", group)

    kinship <- kinship %>%
        left_join(annot, by=c(ID1="sample.id")) %>%
        rename_(group1=group) %>%
        left_join(annot, by=c(ID2="sample.id")) %>%
        rename_(group2=group)

    kinship.group <- kinship %>%
        filter(group1 == group2) %>%
        rename(group=group1) %>%
        select(-group2)

    p <- ggplot(kinship.group, aes_string(xvar, "kinship")) +
        geom_hline(yintercept=2^(-seq(3,11,2)/2), linetype='dashed', color="grey") +
        ## geom_point(alpha=0.5) +
        ## theme_bw()
        facet_wrap(~group) +
        geom_hex(aes(fill = log10(..count..)), bins = 100) +
        ylab("kinship estimate")

    ggsave(paste0(argv$out_prefix, "_within_group.pdf"), plot=p, width=7, height=7)

    ## only plot cross-group for king --ibdseg or --pcrelate
    if (kin.type %in% c("king_ibdseg", "pcrelate")) {
        # only plot cross-group relatives >= Deg2
        kinship.cross <- kinship %>%
            filter(group1 != group2) %>%
            filter(kinship > 2^(-7/2))

        # only make the plot if there are some cross-group kinship pairs
        # leave this one as geom_point instead of hexbin - color-code by group, and not many points
        if (nrow(kinship.cross) > 0){
            p <- ggplot(kinship.cross, aes_string(xvar, "kinship", color="group2")) +
                geom_hline(yintercept=2^(-seq(3,11,2)/2), linetype='dashed', color="grey") +
                geom_point() +
                facet_wrap(~group1, drop=FALSE) +
                ylab("kinship estimate") +
                theme_bw()
            ggsave(paste0(argv$out_prefix, "_cross_group.pdf"), plot=p, width=8, height=7)
        }
    }
}
