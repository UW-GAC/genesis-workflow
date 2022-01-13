
#' Aggregate variant lists
#'
#' Generate GRanges or GRangesList of variants for input to association tests
#'
#' These functions produce output suitable for defining a \code{\link{SeqVarRangeIterator}} or \code{\link{SeqVarListIterator}} object.
#'
#' @param variants A data.frame of variants with columns "group_id", "chr", "pos", "ref", "alt".
#' @return A GRangesList with one element per group
#' @examples
#' library(SeqVarTools)
#' gds <- seqOpen(seqExampleFileName())
#' seqSetFilter(gds, variant.sel=seqGetData(gds, "chromosome") == 22)
#' variants <- data.frame(chr=seqGetData(gds, "chromosome"),
#'                        pos=seqGetData(gds, "position"),
#'                        ref=refChar(gds),
#'                        alt=altChar(gds, n=1),
#'                        stringsAsFactors=FALSE)
#' variants$group_id <- sample(LETTERS[1:2], nrow(variants), replace=TRUE)
#' gr <- aggregateGRangesList(variants)
#' iterator <- SeqVarListIterator(gds, variantRanges=gr)
#'
#' groups <- data.frame(group_id=LETTERS[1:2],
#'                      chr=22,
#'                      start=c(16000000, 2900000),
#'                      end=c(30000000, 49000000),
#' 		     stringsAsFactors=FALSE)
#' gr <- aggregateGRanges(groups)
#' seqResetFilter(gds)
#' iterator <- SeqVarRangeIterator(gds, variantRanges=gr)
#'
#' seqClose(gds)
#' @name aggregateGRanges
#'
#' @importFrom GenomicRanges GRanges GRangesList mcols<-
#' @importFrom IRanges IRanges
#' @importFrom stats setNames
#' @export
aggregateGRangesList <- function(variants) {
    stopifnot(all(c("group_id", "chr", "pos") %in% names(variants)))
    groups <- unique(variants$group_id)
    cols <- setdiff(names(variants), c("group_id", "chr", "pos"))
    GRangesList(lapply(setNames(groups, groups), function(g) {
        x <- variants[variants$group_id == g,]
        gr <- GRanges(seqnames=x$chr, ranges=IRanges(start=x$pos, width=1))
        mcols(gr) <- x[,cols]
        gr
    }))
}


#' @param groups A data.frame of groups with column "group_id", "chr", "start", "end".
#' @return A GRanges with one range per group
#'
#' @rdname aggregateGRanges
#'
#' @importFrom GenomicRanges GRanges mcols<-
#' @importFrom IRanges IRanges
#' @export
aggregateGRanges <- function(groups) {
    stopifnot(all(c("group_id", "chr", "start", "end") %in% names(groups)))
    cols <- setdiff(names(groups), c("group_id", "chr", "start", "end"))
    gr <- GRanges(seqnames=groups$chr,
                  ranges=IRanges(start=groups$start, end=groups$end))
    names(gr) <- groups$group_id
    mcols(gr) <- groups[,cols]
    gr
}
