library(argparser)
library(PipelineHelper)
library(Biobase)
library(dplyr)
library(ggplot2)
library(GGally)
sessionInfo()

argp <- arg_parser("PCA plots")
argp <- add_argument(argp, "--pca_file", 
                     help="RData file with pcair object")
argp <- add_argument(argp, "--n_pairs", default=6, type="integer",
                     help="number of PCs in include in the pairs plot")
argp <- add_argument(argp, "--out_prefix", default="pca", 
                     help="prefix for output files")
argp <- add_argument(argp, "--phenotype_file", 
                     help="RData file with sample.id and group columns")
argp <- add_argument(argp, "--group", 
                     help="Name of column in phenotype_file with group indicator")
argv <- parse_args(argp)
writeParams(argv, "pca_plots.params")

## get PCs
pca <- getobj(argv$pca_file)
pcs <- as.data.frame(pca$vectors[pca$unrels,])
n <- ncol(pcs)
names(pcs) <- paste0("PC", 1:n)
pcs$sample.id <- row.names(pcs)

## scree plot
dat <- data.frame(pc=1:n, varprop=pca$varprop)
p <- ggplot(dat, aes(x=factor(pc), y=100*varprop)) +
  geom_point() + theme_bw() +
  xlab("PC") + ylab("Percent of variance accounted for")
ggsave(paste0(argv$out_prefix, "_scree.pdf"), plot=p, width=6, height=6)

## color by group
if (!is.na(argv$phenotype_file) & !is.na(argv$group)) {
    group <- argv$group
    annot <- getobj(argv$phenotype_file)
    if (is(annot, "AnnotatedDataFrame")) {
        annot <- pData(annot)
    }
    stopifnot(group %in% names(annot))
    annot <- select_(annot, "sample.id", group)
    pcs <- left_join(pcs, annot, by="sample.id")
} else {
    ## make up group
    group <- "group"
    pcs$group <- "NA"
}

p <- ggplot(pcs, aes_string("PC1", "PC2", color=group)) + geom_point(alpha=0.5) +
    guides(colour=guide_legend(override.aes=list(alpha=1)))
ggsave(paste0(argv$out_prefix, "_pc12.pdf"), plot=p, width=7, height=6)


npr <- min(as.integer(argv$n_pairs), n)
p <- ggpairs(pcs, mapping=aes_string(color=group), columns=1:npr,
             lower=list(continuous=wrap("points", alpha=0.5)),
             diag=list(continuous="densityDiag"),
             upper=list(continuous="blank"))
png(paste0(argv$out_prefix, "_pairs.png"), width=8, height=8, units="in", res=150)
print(p)
dev.off()


pc2 <- pcs
names(pc2)[1:ncol(pc2)] <- sub("PC", "", names(pc2)[1:ncol(pc2)])

p <- ggparcoord(pc2, columns=1:n, groupColumn=group, alphaLines=0.5, scale="uniminmax") +
    guides(colour=guide_legend(override.aes=list(alpha=1, size=2))) +
    xlab("PC") + ylab("")
ggsave(paste0(argv$out_prefix, "_parcoord.pdf"), plot=p, width=10, height=5)
