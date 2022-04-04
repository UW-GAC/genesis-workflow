library(argparser)
library(PipelineHelper)
library(SeqArray)
sessionInfo()

argp <- arg_parser("Assign unique variant ids to per-chromosome GDS files")
argp <- add_argument(argp, "--gds_file", nargs=Inf, help="GDS file")
argv <- parse_args(argp)
writeParams(argv, "unique_variant_ids.params")

## exit gracefully if we only have one file
if (length(argv$gds_file) == 1) {
    message("Only one GDS file; no changes needed. Exiting gracefully.")
    q(save="no", status=0)
}

gds.list <- lapply(argv$gds_file, seqOpen, readonly=FALSE)

## put files in order by chromosome
chr <- lapply(gds.list, function(x) {
    seqSetFilter(x, variant.sel=1, verbose=FALSE)
    chrom <- seqGetData(x, "chromosome")
    seqSetFilter(x, verbose=FALSE)
    return(chrom)
})
chr <- factor(unlist(chr), levels=c(1:22, "X", "Y"))
gds.list <- gds.list[order(chr)]


## get total number of variants
var.length <- sapply(gds.list, function(x) {
    objdesp.gdsn(index.gdsn(x, "variant.id"))$dim
})
seqClose(gds.list[[1]])

id.new <- list(1:var.length[1])
for (c in 2:length(gds.list)) {
    id.prev <- id.new[[c-1]]
    last.id <- id.prev[length(id.prev)]
    id.new[[c]] <- (last.id + 1):(last.id + var.length[c])
    stopifnot(length(id.new[[c]]) == var.length[c])
}

for (c in 2:length(gds.list)) {
    node <- index.gdsn(gds.list[[c]], "variant.id")
    desc <- objdesp.gdsn(node)
    stopifnot(desc$dim == length(id.new[[c]]))
    compress <- desc$compress
    compression.gdsn(node, "")
    write.gdsn(node, id.new[[c]])
    compression.gdsn(node, compress)
    seqClose(gds.list[[c]])
}
