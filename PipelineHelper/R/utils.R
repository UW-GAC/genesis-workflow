#' Get an R object stored in an Rdata file
#'
#' Returns an R object stored in an Rdata file
#'
#' Loads an R object and stores it under a new name without creating a duplicate copy.
#' If multiple objects are stored in the same file, only the first one will be returned.
#' Supports files saved with \code{\link{saveRDS}}, provided the file extension ".rds" is used.
#'
#' @param Rdata path to an Rdata file containing a single R object to load
#' @return The R object stored in \code{Rdata}
#' @examples
#' x <- 1:10
#' file <- tempfile()
#' save(x, file=file)
#' y <- getobj(file)
#' unlink(file)
#'
#' @importFrom tools file_ext
#' @export
getobj <- function(Rdata) {
  if (tolower(file_ext(Rdata)) == "rds") {
    return(readRDS(Rdata))
  }
  objname <- load(Rdata)
  if (length(objname) > 1) {
    warning(paste("Multiple objects stored in file", Rdata,
                  "\nReturning only the first object"))
  }
  return(get(objname))
}


#' Generate sequential variant ids
#'
#' Generate sequential variant ids
#'
#' For a set of GDS files each with ids numbered 1:n, convert to sequential ids
#' with 1:N over the combined set of files.
#'
#' @param gds.list List of \code{\link[SeqArray]{SeqVarGDSClass}} objects
#' @param id.list List of vectors of variant ids corresponding to \code{gds.list}
#' @return Vector of sequential variant ids
#'
#' @import SeqArray
#' @export
sequentialVariantIds <- function(gds.list, id.list) {
    stopifnot(length(gds.list) == length(id.list))
    n <- 0
    new.id <- list()
    for (i in seq_along(gds.list)) {
        new.id[[i]] <- id.list[[i]] + n
        ni <- seqSummary(gds.list[[i]], "variant.id")
        n <- n + ni
    }
    stopifnot(all(id.list[[1]] == new.id[[1]]))
    seq.ids <- unlist(new.id)
    stopifnot(sum(duplicated(seq.ids)) == 0)
    return(seq.ids)
}


#' Calculate lambda, the genomic inflation factor
#'
#' @param stat Vector of test statistics
#' @param df Degrees of freedom
#' @param quantiles Quantile(s) at which to calculate lambda value
#' @return lambda calculated at the specified quantiles
#'
#' @importFrom stats qchisq quantile
#' @export
calculateLambda <- function(stat, df, quantiles = 0.5) {
    if (any(sum(stat < 0, na.rm=TRUE)))
        stop("no negative values allowed in stat (does beta/se need to be squared?)")
    unname(quantile(stat, probs = quantiles, na.rm=TRUE) / qchisq(quantiles, df = df))
}


#' Construct filename from prefix and suffix
#'
#' @param prefix prefix
#' @param suffix suffix
#' @param extension extension
#' @return Character string of form "<prefix><sep><suffix>.<extension>"
#'
#' @export
constructFilename <- function(prefix, suffix="", sep="_", extension=".RData") {
    if (nchar(prefix) + nchar(suffix) == 0) stop("must supply either prefix or suffix")
    if (nchar(prefix) == 0) return(paste0(suffix, extension))
    if (nchar(suffix) == 0) return(paste0(prefix, extension))
    return(paste0(prefix, sep, suffix, extension))
}


#' Write each element of a list to a GDS node
#'
#' @param x a list
#' @param file character string with filename of GDS file to create
#'
#' @importFrom gdsfmt createfn.gds add.gdsn closefn.gds
#'
#' @export
list2gds <- function(x, file) {
    gds <- createfn.gds(file)
    for (v in names(x)) {
        if (!is.null(x[[v]])) {
            add.gdsn(gds, v, x[[v]], compress="LZMA_RA")
        }
    }
    closefn.gds(gds)
}


#' Read an ibdobj from a GDS file
#'
#' @param file filename of GDS file
#' @param sample.id vector of sample.id
#' @return Object of type "snpgdsIBDClass"
#'
#' @importFrom gdsfmt openfn.gds closefn.gds index.gdsn read.gdsn readex.gdsn
#'
#' @export
gds2ibdobj <- function(file, sample.id=NULL) {
    f <- openfn.gds(file)
    samp <- read.gdsn(index.gdsn(f, "sample.id"))
    if (!is.null(sample.id)) {
        samp.sel <- samp %in% sample.id
        sample.id <- samp[samp.sel]
    } else {
        samp.sel <- NULL
        sample.id <- samp
    }
    rv <- list(sample.id=sample.id,
               snp.id=read.gdsn(index.gdsn(f, "snp.id")),
               IBS0=readex.gdsn(index.gdsn(f, "IBS0"), sel=list(samp.sel, samp.sel)),
               kinship=readex.gdsn(index.gdsn(f, "kinship"), sel=list(samp.sel, samp.sel)))
    closefn.gds(f)
    class(rv) <- "snpgdsIBDClass"
    return(rv)
}


#' Return a kinship object for use in pcairPartition
#'
#' @param file filename with kinship object (.gds or .RData)
#' @return If file is a GDS file, a GDS object providing a file connection. Otherwise, the R object stored in file.
#'
#' @importFrom gdsfmt openfn.gds
#'
#' @export
kinobj <- function(file) {
    if (tools::file_ext(file) == "gds") {
        x <- openfn.gds(file)
    } else {
        x <- getobj(file)
    }
    x
}


#' Return the median kinship value from a matrix
#'
#' @param mat A kinship matrix
#' @return The median kinship value
#'
#' @importFrom stats median
#'
#' @export
medianKinship <- function(mat) {
    median(mat[lower.tri(mat)])
}
