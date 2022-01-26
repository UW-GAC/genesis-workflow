library(argparser)
library(PipelineHelper)
library(GENESIS)
sessionInfo()

argp <- arg_parser("Format KING results as Matrix")
argp <- add_argument(argp, "--king_file", 
                     help="file with KING output")
argp <- add_argument(argp, "--out_file", default="king_Matrix.RData", 
                     help="output file name")
argp <- add_argument(argp, "--kinship_method", default="king_ibdseg", 
                     help="KING algorithm used")
argp <- add_argument(argp, "--sparse_threshold", default=0.01104854, 
                     help="threshold for sparsity, default 2^(-13/2), 5th degree")
argp <- add_argument(argp, "--sample_include_file", 
                     help="RData file with vector of sample.id to include")
argv <- parse_args(argp)
writeParams(argv, "king_to_matrix.params")

if (!is.na(argv$sample_include_file)) {
    sample.id <- getobj(argv$sample_include_file)
} else {
    sample.id <- NULL
}

if (!is.na(argv$sparse_threshold)) {
    kin.thresh <- argv$sparse_threshold
} else {
    kin.thresh <- NULL
}

kin.type <- tolower(argv$kinship_method)
if (kin.type == "king_ibdseg") {
    estimator <- "PropIBD"
} else {
    estimator <- "Kinship"
}

mat <- kingToMatrix(king=argv$king_file,
                    estimator=estimator,
                    sample.include=sample.id,
                    thresh=kin.thresh)

save(mat, file=argv$out_file)
