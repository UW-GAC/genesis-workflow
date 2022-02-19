library(argparser)
library(PipelineHelper)
library(gdsfmt)
library(dplyr)
library(tidyr)
library(ggplot2)
library(RColorBrewer)
sessionInfo()

argp <- arg_parser("PCA correlation plots")
argp <- add_argument(argp, "--corr_file", nargs=Inf,
                     help="path to config file")
argp <- add_argument(argp, "--n_pcs", default=20, type="integer",
                     help="Number of PCs to plot")
argp <- add_argument(argp, "--n_perpage", default=4, type="integer",
                     help="Number of plots to stack in a single png")
argp <- add_argument(argp, "--out_prefix", default="pca_corr",
                     help="prefix for output files")
argp <- add_argument(argp, "--thin", default=TRUE,
                     help="Logical for whether to thin points")
argv <- parse_args(argp)
writeParams(argv, "pca_corr_plots.params")

corr <- do.call(rbind, lapply(argv$corr_file, function(f) {
    c <- openfn.gds(f)
    dat <- t(read.gdsn(index.gdsn(c, "correlation")))
    n_pcs <- min(argv$n_pcs, ncol(dat))
    dat <- dat[,1:n_pcs]
    missing <- rowSums(is.na(dat)) == n_pcs # monomorphic variants
    dat <- dat[!missing,]
    colnames(dat) <- paste0("PC", 1:n_pcs)
    dat <- data.frame(dat,
                      chr=readex.gdsn(index.gdsn(c, "chromosome"), sel=!missing),
                      pos=readex.gdsn(index.gdsn(c, "position"), sel=!missing),
                      stringsAsFactors=FALSE)
    closefn.gds(c)

    ## transform to data frame with PC as column
    dat <- dat %>%
        gather(PC, value, -chr, -pos) %>%
        filter(!is.na(value)) %>%
        mutate(value=abs(value)) %>%
        mutate(PC=factor(PC, levels=paste0("PC", 1:n_pcs)))

    ## thin points
    ## take up to 10,000 points from each of 10 evenly spaced bins
    if (argv$thin) {
        dat <- thinPoints(dat, "value", n=10000, nbins=10, groupBy="PC")
    }

    dat
}))

## make chromosome a factor so they are plotted in order
corr <- mutate(corr, chr=factor(chr, levels=c(1:22, "X")))
chr <- levels(corr$chr)
cmap <- setNames(rep_len(brewer.pal(8, "Dark2"), length(chr)), chr)

# plot over multiple pages
n_pcs <- length(unique(corr$PC))
n_plots <- ceiling(n_pcs/argv$n_perpage)
bins <- as.integer(cut(1:n_pcs, n_plots))
for (i in 1:n_plots) {
    bin <- paste0("PC", which(bins == i))
    dat <- filter(corr, PC %in% bin)

    p <- ggplot(dat, aes(chr, value, group=interaction(chr, pos), color=chr)) +
        geom_point(position=position_dodge(0.8)) +
        facet_wrap(~PC, scales="free", ncol=1) +
        scale_color_manual(values=cmap, breaks=names(cmap)) +
        ylim(0,1) +
        theme_bw() +
        theme(legend.position="none") +
        theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank()) +
        xlab("chromosome") + ylab("abs(correlation)")
    ggsave(paste0(argv$out_prefix, "_" , i, ".png"), plot=p, width=10, height=15)
}
